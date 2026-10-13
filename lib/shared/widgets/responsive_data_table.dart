import 'package:flutter/material.dart';
import '../../core/design_system/app_spacing.dart';
import '../../l10n/generated/app_localizations.dart';
import 'app_card.dart';
import 'empty_state_view.dart';

class TableColumnDef {
  const TableColumnDef({
    required this.label,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final int flex;
  final Alignment alignment;
}

class ResponsiveDataTable<T> extends StatelessWidget {
  const ResponsiveDataTable({
    super.key,
    required this.items,
    required this.columns,
    required this.rowBuilder,
    required this.mobileCardBuilder,
    this.isLoading = false,
    this.emptyTitle,
    this.emptyMessage,
    this.onEmptyAction,
    this.emptyActionLabel,
    this.onItemTap,
  });

  final List<T> items;
  final List<TableColumnDef> columns;
  final List<Widget> Function(BuildContext context, T item, int index) rowBuilder;
  final Widget Function(BuildContext context, T item, int index) mobileCardBuilder;
  final bool isLoading;

  /// Defaults to the localized "No records found" title.
  final String? emptyTitle;
  final String? emptyMessage;
  final VoidCallback? onEmptyAction;
  final String? emptyActionLabel;
  final ValueChanged<T>? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (items.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return EmptyStateView(
        title: emptyTitle ?? l10n?.noRecordsTitle ?? 'No records found',
        message: emptyMessage,
        actionLabel: emptyActionLabel,
        onAction: onEmptyAction,
      );
    }

    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: onItemTap != null ? () => onItemTap!(item) : null,
            borderRadius: BorderRadius.circular(12),
            child: mobileCardBuilder(context, item, index),
          );
        },
      );
    }

    final theme = Theme.of(context);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: columns.map((col) {
                return Expanded(
                  flex: col.flex,
                  child: Align(
                    alignment: col.alignment,
                    child: Text(
                      col.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final cells = rowBuilder(context, item, index);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onItemTap != null ? () => onItemTap!(item) : null,
                  hoverColor: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: List.generate(columns.length, (colIdx) {
                        final col = columns[colIdx];
                        final cell = colIdx < cells.length ? cells[colIdx] : const SizedBox.shrink();
                        return Expanded(
                          flex: col.flex,
                          child: Align(
                            alignment: col.alignment,
                            child: cell,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
