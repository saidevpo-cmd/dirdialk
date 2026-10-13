import 'package:flutter/material.dart';
import '../../core/design_system/app_spacing.dart';
import '../../l10n/generated/app_localizations.dart';

class SearchAndFilterBar extends StatelessWidget {
  const SearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    this.searchHint,
    this.filterWidgets = const [],
    this.trailingAction,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  /// Defaults to the localized "Search..." hint.
  final String? searchHint;
  final List<Widget> filterWidgets;
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);
    final l10n = AppLocalizations.of(context);
    final hint = searchHint ?? l10n?.searchDefaultHint ?? 'Search...';
    final clearLabel = l10n?.actionClear ?? 'Clear';

    final searchField = Semantics(
      textField: true,
      label: hint,
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  tooltip: clearLabel,
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                )
              : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        ),
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          if (filterWidgets.isNotEmpty || trailingAction != null) ...[
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...filterWidgets,
                  if (trailingAction != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    trailingAction!,
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: searchField,
        ),
        const SizedBox(width: AppSpacing.md),
        ...filterWidgets.map(
          (w) => Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: w,
          ),
        ),
        if (trailingAction != null) ...[
          const Spacer(),
          trailingAction!,
        ],
      ],
    );
  }
}
