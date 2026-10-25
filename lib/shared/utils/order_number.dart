/// Display helpers for human-facing order numbers.
///
/// Order numbers are stored exactly as issued (`#7`, `ORD-1`, `ORD-XXXX-ABCD`)
/// because they are part of the public tracking contract — the customer types
/// the number they were given and `track_order()` matches it literally. Nothing
/// here rewrites the stored value; [OrderNumber.format] is a *presentation*
/// helper only, so callers must never feed its output back into the repository.
///
/// The business wants sequential numbers shown as zero-padded integers
/// (`7` → `#007`, `1048` → `#1048`), which is what format does. Numbers that
/// are not plain integers (the checkout-generated `ORD-…` labels) are returned
/// unchanged rather than mangled.
abstract final class OrderNumber {
  /// Minimum width of the numeric part when padding with zeros.
  static const int padding = 3;

  /// Renders [raw] for display, zero-padding a purely numeric value to
  /// [padding] digits and keeping a leading `#`.
  ///
  /// Examples: `'#7'` → `'#007'`, `'42'` → `'#0042'`, `'#1048'` → `'#1048'`,
  /// `'ORD-1-ABCD'` → `'ORD-1-ABCD'`, `''` → `''`.
  static String format(String raw, {int padding = OrderNumber.padding}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;

    final core =
        trimmed.startsWith('#') ? trimmed.substring(1).trim() : trimmed;
    final value = int.tryParse(core);
    if (value == null || value < 0) return trimmed;
    return '#${value.toString().padLeft(padding, '0')}';
  }
}
