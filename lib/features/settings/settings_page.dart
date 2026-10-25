import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_info.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design_system/app_spacing.dart';
import '../../core/design_system/app_style.dart';
import '../../core/settings/settings_controller.dart';
import '../../data/app_repositories.dart';
import '../../data/demo/demo_data_seeder.dart';
import '../../domain/models/app_error.dart';
import '../../domain/models/site_settings.dart';
import '../../domain/models/social_links.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/utils/app_feedback.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/social_links_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.settings, this.auth});

  final SettingsController settings;

  /// Optional authentication controller. When a backend is configured the
  /// settings page exposes an account/sign-out section.
  final AuthController? auth;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _query = '';

  SettingsController get settings => widget.settings;

  /// Storefront social links, edited here and persisted to `site_settings`.
  final Map<SocialPlatform, TextEditingController> _socialCtrls = {
    for (final platform in SocialPlatform.values)
      platform: TextEditingController(),
  };
  bool _socialLoading = true;
  bool _socialSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSiteSettings();
  }

  @override
  void dispose() {
    for (final controller in _socialCtrls.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Loads the public site settings and fills the social-link editors. A
  /// failure leaves the fields empty rather than blocking the whole page.
  Future<void> _loadSiteSettings() async {
    final result = await AppRepositories.instance.siteSettings.load();
    if (!mounted) return;
    setState(() {
      _socialLoading = false;
      if (result is Success<SiteSettings>) {
        final links = result.data.socialLinks;
        for (final platform in SocialPlatform.values) {
          _socialCtrls[platform]!.text = links.url(platform) ?? '';
        }
      }
    });
  }

  SocialLinks _collectSocialLinks() {
    var links = SocialLinks.empty;
    for (final platform in SocialPlatform.values) {
      final raw = _socialCtrls[platform]!.text;
      if (raw.trim().isEmpty) continue;
      final normalized = SocialLinks.normalize(platform, raw);
      if (normalized != null) {
        links = links.withLink(platform, normalized);
      }
    }
    return links;
  }

  /// Validation message for a field, or `null` when it is empty/valid.
  String? _socialFieldError(SocialPlatform platform, AppLocalizations l10n) {
    final raw = _socialCtrls[platform]!.text.trim();
    if (raw.isEmpty) return null;
    return SocialLinks.normalize(platform, raw) == null
        ? l10n.socialInvalidUrl
        : null;
  }

  Future<void> _saveSocialLinks() async {
    final l10n = AppLocalizations.of(context)!;
    if (SocialPlatform.values
        .any((platform) => _socialFieldError(platform, l10n) != null)) {
      // Surface the errors (already shown inline) without a round trip.
      setState(() {});
      AppFeedback.failure(context, l10n.socialInvalidUrl);
      return;
    }

    setState(() => _socialSaving = true);
    final repo = AppRepositories.instance.siteSettings;
    final loaded = await repo.load();
    if (!mounted) return;
    final base = loaded is Success<SiteSettings>
        ? loaded.data
        : const SiteSettings();
    final result =
        await repo.save(base.copyWith(socialLinks: _collectSocialLinks()));
    if (!mounted) return;
    setState(() {
      _socialSaving = false;
    });
    AppFeedback.fromResult(context, result, successMessage: l10n.saved);
  }

  bool _matches(String title, String description) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final config = context.styleConfig;
    final width = MediaQuery.sizeOf(context).width;
    final scale = config.spacingScale;
    final grouped = _buildGroups(l10n, theme, scale);

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
            TextField(
              key: const Key('settings-search'),
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: l10n.settingsSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.lg * scale),
            if (grouped.every((w) => w is SizedBox))
              _buildNoResults(l10n, theme)
            else
              for (final child in grouped) ...[
                child,
                SizedBox(height: AppSpacing.xl * scale),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(AppLocalizations l10n, ThemeData theme) {
    return AppCard(
      expand: true,
      child: Column(
        children: [
          Icon(Icons.search_off, size: 40, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            l10n.settingsNoResults(_query.trim()),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroups(
    AppLocalizations l10n,
    ThemeData theme,
    double scale,
  ) {
    return [
      _buildGroup(
        icon: Icons.tune,
        title: l10n.sectionGeneral,
        description: l10n.sectionGeneralDesc,
        theme: theme,
        children: [
          _buildLanguage(l10n, theme, scale),
          _buildAppearance(l10n, theme, scale),
          _buildStyle(l10n, theme, scale),
        ],
      ),
      _buildGroup(
        icon: Icons.share_outlined,
        title: l10n.socialMedia,
        description: l10n.socialMediaHint,
        theme: theme,
        children: [_buildSocial(l10n, theme)],
      ),
      _buildGroup(
        icon: Icons.notifications_outlined,
        title: l10n.sectionNotifications,
        description: l10n.sectionNotificationsDesc,
        theme: theme,
        children: [
          _buildCard(
            [
              _switchTile(
                key: const Key('notify-orders'),
                title: l10n.notifOrders,
                description: l10n.notifOrdersDesc,
                value: settings.notifyOrders,
                onChanged: settings.setNotifyOrders,
              ),
              _switchTile(
                key: const Key('notify-low-stock'),
                title: l10n.notifLowStock,
                description: l10n.notifLowStockDesc,
                value: settings.notifyLowStock,
                onChanged: settings.setNotifyLowStock,
              ),
              _switchTile(
                key: const Key('notify-weekly'),
                title: l10n.notifWeekly,
                description: l10n.notifWeeklyDesc,
                value: settings.notifyWeekly,
                onChanged: settings.setNotifyWeekly,
              ),
            ],
          ),
        ],
      ),
      _buildGroup(
        icon: Icons.privacy_tip_outlined,
        title: l10n.sectionPrivacy,
        description: l10n.sectionPrivacyDesc,
        theme: theme,
        children: [
          _buildCard(
            [
              _switchTile(
                key: const Key('privacy-analytics'),
                title: l10n.privacyAnalytics,
                description: l10n.privacyAnalyticsDesc,
                value: settings.privacyAnalytics,
                onChanged: settings.setPrivacyAnalytics,
              ),
              _switchTile(
                key: const Key('privacy-crash'),
                title: l10n.privacyCrash,
                description: l10n.privacyCrashDesc,
                value: settings.privacyCrash,
                onChanged: settings.setPrivacyCrash,
              ),
              _switchTile(
                key: const Key('privacy-personalization'),
                title: l10n.privacyPersonalization,
                description: l10n.privacyPersonalizationDesc,
                value: settings.privacyPersonalization,
                onChanged: settings.setPrivacyPersonalization,
              ),
              const Divider(height: 1),
              _actionTile(
                key: const Key('privacy-policy-action'),
                title: l10n.privacyPolicyAction,
                description: l10n.privacyPolicyActionDesc,
                icon: Icons.description_outlined,
                onTap: () => _showPolicyDialog(
                  context,
                  title: l10n.privacyPolicyTitle,
                  sections: _privacySections(l10n),
                ),
              ),
              _actionTile(
                key: const Key('terms-action'),
                title: l10n.termsAction,
                description: l10n.termsActionDesc,
                icon: Icons.gavel_outlined,
                onTap: () => _showPolicyDialog(
                  context,
                  title: l10n.termsTitle,
                  sections: _termsSections(l10n),
                ),
              ),
            ],
          ),
          _buildConsent(l10n, theme),
        ],
      ),
      _buildGroup(
        icon: Icons.storage_outlined,
        title: l10n.sectionData,
        description: l10n.sectionDataDesc,
        theme: theme,
        children: [
          _buildCard(
            [
              _infoTile(
                title: l10n.dataStorage,
                description: l10n.dataStorageDesc,
                icon: Icons.save_outlined,
              ),
              _actionTile(
                key: const Key('data-export'),
                title: l10n.dataExport,
                description: l10n.dataExportDesc,
                icon: Icons.file_download_outlined,
                onTap: () => _exportSettings(context),
              ),
              _actionTile(
                key: const Key('data-demo'),
                title: l10n.demoDataTitle,
                description: l10n.demoDataDesc,
                icon: Icons.auto_awesome_outlined,
                onTap: _loadDemoData,
              ),
              _actionTile(
                key: const Key('data-reset'),
                title: l10n.dataReset,
                description: l10n.dataResetDesc,
                icon: Icons.restore_outlined,
                onTap: () => _confirmReset(context),
              ),
            ],
          ),
        ],
      ),
      if (widget.auth?.isBackendConfigured ?? false) _buildAccount(l10n, theme),
      _buildGroup(
        icon: Icons.info_outline,
        title: l10n.sectionAbout,
        description: l10n.sectionAboutDesc,
        theme: theme,
        children: [
          _buildCard(
            [
              _infoTile(
                title: l10n.aboutVersion,
                description: AppInfo.version,
                icon: Icons.tag_outlined,
              ),
              _infoTile(
                title: l10n.aboutBuild,
                description: AppInfo.buildNumber,
                icon: Icons.build_outlined,
              ),
              _actionTile(
                key: const Key('about-licenses'),
                title: l10n.aboutLicenses,
                description: l10n.aboutLicensesDesc,
                icon: Icons.menu_book_outlined,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                  applicationVersion:
                      '${AppInfo.version}+${AppInfo.buildNumber}',
                ),
              ),
              _actionTile(
                key: const Key('about-contact'),
                title: l10n.aboutContact,
                description: l10n.aboutContactDesc,
                icon: Icons.mail_outline,
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(text: AppInfo.contactEmail),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.actionCopied)),
                    );
                  }
                },
              ),
              _infoTile(
                title: l10n.aboutOffline,
                description: l10n.aboutOfflineDesc,
                icon: Icons.offline_pin_outlined,
              ),
            ],
          ),
        ],
      ),
    ].whereType<Widget>().toList();
  }

  /// Editor for the public storefront social links (includes WhatsApp).
  Widget _buildSocial(AppLocalizations l10n, ThemeData theme) {
    return _buildCard([
      if (_socialLoading)
        const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Center(child: CircularProgressIndicator()),
        )
      else ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              for (final platform in SocialPlatform.values) ...[
                TextField(
                  key: Key('social-${platform.name}'),
                  controller: _socialCtrls[platform],
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: socialPlatformLabel(l10n, platform),
                    hintText: platform == SocialPlatform.whatsapp
                        ? '${l10n.socialUrlLabel} / +212600000000'
                        : l10n.socialUrlLabel,
                    prefixIcon: Icon(socialPlatformIcon(platform)),
                    errorText: _socialFieldError(platform, l10n),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            key: const Key('social-save'),
            onPressed: _socialSaving ? null : _saveSocialLinks,
            icon: _socialSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.actionSaveChanges),
          ),
        ),
      ],
    ]);
  }

  Widget _buildGroup({
    required IconData icon,
    required String title,
    required String description,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    if (!_matches(title, description)) return const SizedBox.shrink();
    return Column(
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
        SizedBox(height: AppSpacing.md),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.md),
          children[i],
        ],
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return AppCard(
      expand: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _buildAccount(
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final auth = widget.auth!;
    final signedInAs = auth.email == null
        ? l10n.accountLocalMode
        : l10n.accountSignedInAs(auth.email!);
    return _buildGroup(
      icon: Icons.person_outline,
      title: l10n.accountTitle,
      description: l10n.accountDescription,
      theme: theme,
      children: [
        _buildCard([
          _infoTile(
            title: auth.email ?? l10n.accountTitle,
            description: signedInAs,
            icon: Icons.badge_outlined,
          ),
          _actionTile(
            key: const Key('account-sign-out'),
            title: l10n.signOut,
            description: signedInAs,
            icon: Icons.logout,
            onTap: () => _confirmSignOut(context, l10n),
          ),
        ]),
      ],
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const Key('sign-out-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.signOutConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await widget.auth?.signOut();
    }
  }

  Widget _switchTile({
    required Key key,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        key: key,
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        subtitle: Text(description),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _infoTile({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }

  Widget _actionTile({
    required Key key,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        key: key,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguage(
    AppLocalizations l10n,
    ThemeData theme,
    double scale,
  ) {
    final current = settings.locale ?? const Locale('en');
    return _buildSectionCard(
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
              onSelected: (_) => settings.setLocale(Locale(entry.key)),
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
    return _buildSectionCard(
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

  Widget _buildStyle(AppLocalizations l10n, ThemeData theme, double scale) {
    final description = switch (settings.style) {
      AppStyle.modern => l10n.styleModernDesc,
      AppStyle.minimal => l10n.styleMinimalDesc,
      AppStyle.professional => l10n.styleProfessionalDesc,
    };

    return _buildSectionCard(
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

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String description,
    required Widget child,
    required ThemeData theme,
    required double scale,
  }) {
    return _buildCard([
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
    ]);
  }

  Widget _buildConsent(AppLocalizations l10n, ThemeData theme) {
    final accepted = settings.consentAcceptedAt;
    final status = accepted != null
        ? l10n.consentAccepted(_formatDate(accepted))
        : l10n.consentPending;
    return AppCard(
      expand: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.consentTitle,
                    style: theme.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              key: const Key('consent-review'),
              onPressed: () => _showConsentDialog(context),
              icon: const Icon(Icons.rate_review_outlined, size: 20),
              label: Text(l10n.consentAction),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showConsentDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.privacyPolicyTitle),
        scrollable: true,
        content: _policyBody(
          context,
          sections: _privacySections(l10n),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.policyNotNow),
          ),
          FilledButton(
            key: const Key('consent-accept'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.policyAccept),
          ),
        ],
      ),
    );
    if (accepted == true && context.mounted) {
      await settings.acceptConsent();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.consentAcceptedToast)),
        );
      }
    }
  }

  List<({String title, String body})> _privacySections(AppLocalizations l10n) =>
      [
        (title: l10n.privacyIntroTitle, body: l10n.privacyIntro),
        (
          title: l10n.privacyCollectTitle,
          body: l10n.privacyCollectBody,
        ),
        (
          title: l10n.privacyOptionalTitle,
          body: l10n.privacyOptionalBody,
        ),
        (title: l10n.privacyLocalTitle, body: l10n.privacyLocalBody),
        (title: l10n.privacyRightsTitle, body: l10n.privacyRightsBody),
        (
          title: l10n.privacyContactTitle,
          body: l10n.privacyContactBody(AppInfo.contactEmail),
        ),
        (
          title: l10n.privacyUpdatedTitle,
          body: l10n.privacyUpdatedOn(AppInfo.policyUpdatedOn),
        ),
      ];

  List<({String title, String body})> _termsSections(AppLocalizations l10n) => [
        (title: l10n.termsAcceptTitle, body: l10n.termsAcceptBody),
        (title: l10n.termsUseTitle, body: l10n.termsUseBody),
        (title: l10n.termsAvailabilityTitle, body: l10n.termsAvailabilityBody),
        (title: l10n.termsLiabilityTitle, body: l10n.termsLiabilityBody),
        (title: l10n.termsChangesTitle, body: l10n.termsChangesBody),
        (
          title: l10n.termsContactTitle,
          body: l10n.termsContactBody(AppInfo.contactEmail),
        ),
      ];

  Future<void> _showPolicyDialog(
    BuildContext context, {
    required String title,
    required List<({String title, String body})> sections,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        scrollable: true,
        content: _policyBody(context, sections: sections),
        actions: [
          TextButton(
            key: const Key('policy-close'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.actionClose),
          ),
        ],
      ),
    );
  }

  Widget _policyBody(
    BuildContext context, {
    required List<({String title, String body})> sections,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          Text(
            sections[i].title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(sections[i].body, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }

  Future<void> _exportSettings(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final json = const JsonEncoder.withIndent('  ')
        .convert(settings.exportPreferences());
    final shouldCopy = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dataExportTitle),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionClose),
          ),
          FilledButton.icon(
            key: const Key('export-copy'),
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.copy, size: 18),
            label: Text(l10n.actionCopy),
          ),
        ],
      ),
    );
    if (shouldCopy == true && context.mounted) {
      await Clipboard.setData(ClipboardData(text: json));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.actionCopied)),
        );
      }
    }
  }

  Future<void> _loadDemoData() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(l10n.demoDataLoading)));

    final DemoSeedResult result;
    try {
      result = await AppRepositories.instance.demoSeeder.seed();
    } catch (_) {
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(l10n.demoDataFailed)));
      return;
    }

    if (!mounted) return;
    messenger.hideCurrentSnackBar();
    final message = result.alreadyLoaded
        ? l10n.demoDataAlready
        : l10n.demoDataResult(result.productsAdded, result.categoriesAdded);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dataResetTitle),
        content: Text(l10n.dataResetBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const Key('reset-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.dataResetConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await settings.resetAll(
        deviceLocale: WidgetsBinding.instance.platformDispatcher.locale,
      );
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}