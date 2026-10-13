import 'package:flutter/material.dart';

import '../../core/design_system/app_style.dart';
import '../../core/navigation/nav_section.dart';
import '../../l10n/generated/app_localizations.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.section});

  final NavSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final config = context.styleConfig;

    return Center(
      key: ValueKey('placeholder-${section.name}'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius:
                      BorderRadius.circular(config.cardRadius + 8),
                ),
                child: Icon(
                  section.icon(selected: true),
                  size: 44,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                section.label(l10n),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Chip(
                backgroundColor: scheme.secondaryContainer,
                side: BorderSide.none,
                label: Text(
                  'Phase ${section.phase}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.actionComingSoon,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
