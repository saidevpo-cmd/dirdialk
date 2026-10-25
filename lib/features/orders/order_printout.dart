import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/models/order.dart';
import '../../domain/models/site_settings.dart';
import '../../l10n/generated/app_localizations.dart';
import 'order_document.dart';

/// Seam over the platform print/download pipeline.
///
/// The page talks to this interface so widget tests can capture the produced
/// bytes without the `printing` plugin's platform channels, while production
/// uses [PrintingOrderPrintActions].
abstract class OrderPrintActions {
  /// Opens the system print dialog for [pdf].
  Future<void> print(Uint8List pdf, String filename);

  /// Hands [pdf] to the platform share/save sheet (a file download on web).
  Future<void> download(Uint8List pdf, String filename);
}

/// Production implementation backed by the `printing` package.
class PrintingOrderPrintActions implements OrderPrintActions {
  const PrintingOrderPrintActions();

  @override
  Future<void> print(Uint8List pdf, String filename) =>
      Printing.layoutPdf(onLayout: (_) async => pdf);

  @override
  Future<void> download(Uint8List pdf, String filename) =>
      Printing.sharePdf(bytes: pdf, filename: filename);
}

/// Builds the A4 printable/reprintable document for a stored order.
///
/// The document is a faithful projection of the order row: it is built from
/// [OrderDocument.fromOrder], which never consults current product prices and
/// never invents missing values. Arabic (and any RTL locale) is rendered with
/// the bundled Cairo font and the package's Arabic shaping + bidi support,
/// with the whole layout mirrored via [pw.Directionality].
class OrderPrintout {
  const OrderPrintout._();

  static const String _regularFont = 'assets/fonts/Cairo-Regular.ttf';
  static const String _boldFont = 'assets/fonts/Cairo-Bold.ttf';

  /// Renders [order] as an A4 PDF using only its stored data.
  ///
  /// [currencySymbol] and the brand block come from site settings (display
  /// metadata), never from live product data. [rtl] mirrors the layout for
  /// Arabic; labels come from [l10n].
  ///
  /// The order number is rendered **verbatim** — no display padding — so the
  /// printed value always matches what `track_order()` accepts when the
  /// customer retypes it from the receipt.
  static Future<Uint8List> buildPdf({
    required Order order,
    required AppLocalizations l10n,
    required SiteSettings settings,
    required String currencySymbol,
    required bool rtl,
  }) async {
    final data = OrderDocument.fromOrder(
      order,
      currencySymbol: currencySymbol,
    );
    final labels = _Labels(l10n);
    final theme = await _theme();
    final direction = rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final now = OrderDocument.formatDateTime(DateTime.now());

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: theme,
        build: (context) => [
          pw.Directionality(
            textDirection: direction,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _header(data: data, settings: settings, labels: labels),
                pw.SizedBox(height: 16),
                _meta(data: data, labels: labels),
                if (data.hasCustomerInfo) ...[
                  pw.SizedBox(height: 12),
                  _customer(data: data, labels: labels),
                ],
                pw.SizedBox(height: 14),
                _items(data: data, labels: labels),
                pw.SizedBox(height: 14),
                _totals(data: data, labels: labels, rtl: rtl),
                if (data.notes != null) ...[
                  pw.SizedBox(height: 12),
                  _notes(data: data, labels: labels),
                ],
              ],
            ),
          ),
        ],
        footer: (context) => pw.Directionality(
          textDirection: direction,
          child: pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey400, width: 0.6),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    labels.reprintFooter(now),
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
                pw.Text(
                  '${context.pageNumber} / ${context.pagesCount}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return pdf.save();
  }

  /// Filesystem-safe download name (`order-ORD-123.pdf`): separators are
  /// collapsed and edge dashes trimmed so `#1048` becomes `order-1048.pdf`.
  static String filenameFor(Order order) {
    final safe = order.orderNumber
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return 'order-${safe.isEmpty ? 'document' : safe}.pdf';
  }

  // ------------------------------------------------------------------
  // Document sections
  // ------------------------------------------------------------------

  static pw.Widget _header({
    required OrderDocument data,
    required SiteSettings settings,
    required _Labels labels,
  }) {
    final c = settings.customization;
    final contact = [
      if (c.contactPhone.trim().isNotEmpty) c.contactPhone.trim(),
      if (c.contactEmail.trim().isNotEmpty) c.contactEmail.trim(),
      if (c.address.trim().isNotEmpty) c.address.trim(),
    ].join(' · ');

    const brandStyle = pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold);
    const small = pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700);

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey500, width: 1),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (c.brandName.trim().isNotEmpty)
                  pw.Text(c.brandName.trim(), style: brandStyle),
                if (c.tagline.trim().isNotEmpty)
                  pw.Text(c.tagline.trim(), style: small),
                if (contact.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(contact, style: small),
                ],
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                labels.documentTitle,
                style: const pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                labels.orderNumberLine(data.orderNumber),
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _meta({
    required OrderDocument data,
    required _Labels labels,
  }) {
    pw.Widget kv(String label, String value) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                value,
                textAlign: pw.TextAlign.end,
                style: const pw.TextStyle(fontSize: 9.5),
              ),
            ),
          ],
        );

    return pw.Column(
      children: [
        kv(labels.orderDateLabel, data.createdAt),
        kv(labels.statusLabel, labels.status(data.status)),
        if (data.paidAt != null) kv(labels.paidLabel, data.paidAt!),
        if (data.deliveredAt != null)
          kv(labels.deliveredLabel, data.deliveredAt!),
        if (data.cancelledAt != null)
          kv(labels.cancelledLabel, data.cancelledAt!),
      ],
    );
  }

  static pw.Widget _customer({
    required OrderDocument data,
    required _Labels labels,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            labels.customerInformation,
            style: const pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          for (final field in data.customerFields)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    labels.field(field.key),
                    style: const pw.TextStyle(
                      fontSize: 9.5,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      field.value,
                      textAlign: pw.TextAlign.end,
                      style: const pw.TextStyle(fontSize: 9.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _items({
    required OrderDocument data,
    required _Labels labels,
  }) {
    const headStyle = pw.TextStyle(
      fontSize: 8.5,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey700,
    );
    const cellStyle = pw.TextStyle(fontSize: 9.5);

    pw.Widget headCell(String text, int flex, pw.TextAlign align) =>
        pw.Expanded(
          flex: flex,
          child: pw.Text(text, textAlign: align, style: headStyle),
        );

    pw.Widget bodyCell(String text, int flex, pw.TextAlign align,
            {pw.TextStyle? style}) =>
        pw.Expanded(
          flex: flex,
          child: pw.Text(text, textAlign: align, style: style ?? cellStyle),
        );

    final headerBorder = pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.grey600, width: 0.8),
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 4),
          decoration: headerBorder,
          child: pw.Row(
            children: [
              headCell('#', 1, pw.TextAlign.center),
              headCell(labels.productColumn, 5, pw.TextAlign.start),
              headCell(labels.qtyColumn, 2, pw.TextAlign.center),
              headCell(labels.unitPriceColumn, 3, pw.TextAlign.end),
              headCell(labels.subtotalColumn, 3, pw.TextAlign.end),
            ],
          ),
        ),
        for (var i = 0; i < data.items.length; i++)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 5),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                bodyCell('${i + 1}', 1, pw.TextAlign.center),
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(data.items[i].name, style: cellStyle),
                      if (data.items[i].sku != null)
                        pw.Text(
                          '${labels.skuColumn}: ${data.items[i].sku}',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey600,
                          ),
                        ),
                    ],
                  ),
                ),
                bodyCell('${data.items[i].qty}', 2, pw.TextAlign.center),
                bodyCell(
                  OrderDocument.money(
                    data.items[i].unitPrice,
                    data.currencySymbol,
                  ),
                  3,
                  pw.TextAlign.end,
                ),
                bodyCell(
                  OrderDocument.money(
                    data.items[i].subtotal,
                    data.currencySymbol,
                  ),
                  3,
                  pw.TextAlign.end,
                ),
              ],
            ),
          ),
        if (data.items.isEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            child: pw.Text(
              labels.itemsColumn,
              style: const pw.TextStyle(
                fontSize: 9.5,
                color: PdfColors.grey600,
              ),
            ),
          ),
      ],
    );
  }

  static pw.Widget _totals({
    required OrderDocument data,
    required _Labels labels,
    required bool rtl,
  }) {
    final block = pw.Column(
      children: [
        for (final line in data.totals)
          line.isGrandTotal
              ? pw.Container(
                  margin: const pw.EdgeInsets.only(top: 6),
                  padding: const pw.EdgeInsets.only(top: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(color: PdfColors.grey600, width: 0.8),
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        labels.total(line.key),
                        style: const pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        OrderDocument.money(line.amount, data.currencySymbol),
                        style: const pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        labels.total(line.key),
                        style: const pw.TextStyle(
                          fontSize: 9.5,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.Text(
                        OrderDocument.money(line.amount, data.currencySymbol),
                        style: const pw.TextStyle(fontSize: 9.5),
                      ),
                    ],
                  ),
                ),
      ],
    );

    // The totals block hugs the end edge. [pw.Alignment] is not directional
    // in the pdf package, so mirror it explicitly for RTL.
    return pw.Align(
      alignment: rtl ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
      child: pw.SizedBox(width: 250, child: block),
    );
  }

  static pw.Widget _notes({
    required OrderDocument data,
    required _Labels labels,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            labels.notesLabel,
            style: const pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(data.notes!, style: const pw.TextStyle(fontSize: 9.5)),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Fonts
  // ------------------------------------------------------------------

  /// Cairo (bundled, full Arabic + Latin coverage) when the asset is
  /// available; otherwise the package default so a missing font can never
  /// break the feature.
  static Future<pw.ThemeData> _theme() async {
    try {
      final base = await rootBundle.load(_regularFont);
      final bold = await rootBundle.load(_boldFont);
      return pw.ThemeData.withFont(
        base: pw.Font.ttf(base),
        bold: pw.Font.ttf(bold),
      );
    } catch (_) {
      return pw.ThemeData.withFont();
    }
  }
}

/// Localized strings for the document, resolved once from [AppLocalizations].
class _Labels {
  _Labels(this.l10n);

  final AppLocalizations l10n;

  String get documentTitle => l10n.orderDocumentTitle;
  String get orderDateLabel => l10n.orderDateLabel;
  String get statusLabel => l10n.colStatus;
  String get customerInformation => l10n.customerInformation;
  String get notesLabel => l10n.notesLabel;
  String get productColumn => l10n.colProduct;
  String get qtyColumn => l10n.colQty;
  String get unitPriceColumn => l10n.unitPriceLabel;
  String get subtotalColumn => l10n.subtotalLabel;
  String get itemsColumn => l10n.colItems;
  String get skuColumn => l10n.colSku;
  String get paidLabel => l10n.statusPaid;
  String get deliveredLabel => l10n.statusDelivered;
  String get cancelledLabel => l10n.statusCancelled;

  String orderNumberLine(String number) =>
      l10n.orderLabel(number).replaceAll(RegExp(r'\s+'), ' ');

  String reprintFooter(String date) => l10n.reprintFooter(date);

  String status(OrderStatus status) => switch (status) {
        OrderStatus.pending => l10n.statusPending,
        OrderStatus.paid => l10n.statusPaid,
        OrderStatus.shipped => l10n.statusShipped,
        OrderStatus.delivered => l10n.statusDelivered,
        OrderStatus.cancelled => l10n.statusCancelled,
      };

  String field(OrderDocumentFieldKey key) => switch (key) {
        OrderDocumentFieldKey.name => l10n.nameLabel,
        OrderDocumentFieldKey.phone => l10n.customerPhoneLabel,
        OrderDocumentFieldKey.email => l10n.emailLabel,
        OrderDocumentFieldKey.address => l10n.addressLabel,
        OrderDocumentFieldKey.city => l10n.customerCityLabel,
      };

  String total(OrderDocumentTotalKey key) => switch (key) {
        OrderDocumentTotalKey.subtotal => l10n.subtotalLabel,
        OrderDocumentTotalKey.discount => l10n.discountLabel,
        OrderDocumentTotalKey.tax => l10n.taxLabel,
        OrderDocumentTotalKey.shipping => l10n.shippingLabel,
        OrderDocumentTotalKey.total => l10n.totalAmountLabel,
      };
}
