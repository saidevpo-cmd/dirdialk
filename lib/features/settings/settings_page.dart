import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../core/design_system/app_style.dart';
import '../../core/settings/settings_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/app_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final config = context.styleConfig;
    final width = MediaQuery.sizeOf(context).width;
    final scale = config.spacingScale;

    return SingleChildScrollView(
      key: const Key('settings-page'),
      padding: AppSpacing.pagePadding(width),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsTitle, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              l10n.settingsSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.lg * scale),
            _buildLanguage(l10n, theme, scale),
            SizedBox(height: AppSpacing.lg * scale),
            _buildAppearance(l10n, theme, scale),
            SizedBox(height: AppSpacing.lg * scale),
            _buildStyle(l10n, theme, scale),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
    required ThemeData theme,
    required double scale,
  }) {
    return AppCard(
      expand: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.md * scale),
          child,
        ],
      ),
    );
  }

  Widget _buildLanguage(
    AppLocalizations l10n,
    ThemeData theme,
    double scale,
  ) {
    final current = settings.locale ?? const Locale('en');
    return _buildSection(
      icon: Icons.language,
      title: l10n.languageTitle,
      description: l10n.languageDescription,
      theme: theme,
      scale: scale,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final entry in const {
            'ar': 'العربية',
            'en': 'English',
            'fr': 'Français',
          }.entries)
            ChoiceChip(
              label: Text(entry.value),
              selected: current.languageCode == entry.key,
              onSelected: (_) =>
                  settings.setLocale(Locale(entry.key)),
            ),
        ],
      ),
    );
  }

  Widget _buildAppearance(
    AppLocalizations l10n,
    ThemeData theme,
    double scale,
  ) {
    return _buildSection(
      icon: Icons.brightness_6_outlined,
      title: l10n.appearanceTitle,
      description: l10n.appearanceDescription,
      theme: theme,
      scale: scale,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text(l10n.modeSystem),
              icon: const Icon(Icons.brightness_auto, size: 18),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text(l10n.modeLight),
              icon: const Icon(Icons.light_mode_outlined, size: 18),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text(l10n.modeDark),
              icon: const Icon(Icons.dark_mode_outlined, size: 18),
            ),
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (selection) =>
              settings.setThemeMode(selection.first),
        ),
      ),
    );
  }

  Widget _buildStyle(
    AppLocalizations l10n,
    ThemeData theme,
    double scale,
  ) {
    final description = switch (settings.style) {
      AppStyle.modern => l10n.styleModernDesc,
      AppStyle.minimal => l10n.styleMinimalDesc,
      AppStyle.professional => l10n.styleProfessionalDesc,
    };

    return _buildSection(
      icon: Icons.style_outlined,
      title: l10n.styleTitle,
      description: l10n.styleDescription,
      theme: theme,
      scale: scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<AppStyle>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: AppStyle.modern,
                  label: Text(l10n.styleModern),
                ),
                ButtonSegment(
                  value: AppStyle.minimal,
                  label: Text(l10n.styleMinimal),
                ),
                ButtonSegment(
                  value: AppStyle.professional,
                  label: Text(l10n.styleProfessional),
                ),
              ],
              selected: {settings.style},
              onSelectionChanged: (selection) =>
                  settings.setStyle(selection.first),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
