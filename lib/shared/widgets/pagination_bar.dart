import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../l10n/generated/app_localizations.dart';

/// Compact pager for repository-backed list pages.
///
/// Renders nothing when everything fits on a single page, so pages that opt in
/// keep their existing look for small datasets. The "showing X-Y of Z" line
/// uses the *filtered* total reported by the repository, not the number of
/// locally-held rows.
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPageChanged,
  });

  /// 1-based current page.
  final int page;
  final int pageSize;

  /// Total number of rows matching the current filters.
  final int total;
  final ValueChanged<int> onPageChanged;

  int get _totalPages =>
      total <= 0 ? 1 : ((total + pageSize - 1) ~/ pageSize);

  @override
  Widget build(BuildContext context) {
    if (total <= pageSize) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final totalPages = _totalPages;
    final first = (page - 1) * pageSize + 1;
    final last = (page * pageSize).clamp(0, total);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              l10n.paginationRange('$first', '$last', '$total'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: const Key('pagination-prev'),
                tooltip: l10n.paginationPrevious,
                onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(l10n.paginationPageOf('$page', '$totalPages')),
              IconButton(
                key: const Key('pagination-next'),
                tooltip: l10n.paginationNext,
                onPressed:
                    page < totalPages ? () => onPageChanged(page + 1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
