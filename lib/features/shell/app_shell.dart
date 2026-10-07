import 'package:flutter/material.dart';

import '../../core/design_system/app_spacing.dart';
import '../../core/design_system/app_style.dart';
import '../../core/navigation/nav_section.dart';
import '../../core/settings/settings_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../dashboard/dashboard_page.dart';
import '../settings/settings_page.dart';
import '../../shared/widgets/placeholder_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.settings});

  final SettingsController settings;

  static const sidebarKey = Key('app-sidebar');
  static const drawerKey = Key('app-drawer');
  static const navRailKey = Key('app-nav-rail');
  static const bodyKey = Key('app-body');
  static const openMenuKey = Key('open-navigation');
  static const quickSettingsKey = Key('quick-settings');

  static Key navTile(NavSection section) => ValueKey('nav-${section.name}');

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  NavSection _current = NavSection.dashboard;

  void _select(NavSection section) {
    if (section == _current) return;
    setState(() => _current = section);
  }

  void _selectFromDrawer(NavSection section) {
    Navigator.of(context).pop();
    _select(section);
  }

  List<Widget> _buildPages() => [
        DashboardPage(onNavigate: _select),
        const PlaceholderPage(section: NavSection.products),
        const PlaceholderPage(section: NavSection.orders),
        const PlaceholderPage(section: NavSection.customers),
        const PlaceholderPage(section: NavSection.resources),
        const PlaceholderPage(section: NavSection.forms),
        const PlaceholderPage(section: NavSection.pages),
        const PlaceholderPage(section: NavSection.store),
        SettingsPage(settings: widget.settings),
      ];

  Widget _buildBody() => KeyedSubtree(
        key: AppShell.bodyKey,
        child: IndexedStack(
          index: _current.index,
          children: _buildPages(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;

    if (AppBreakpoints.isDesktop(width)) {
      return _buildDesktop(l10n);
    }
    if (!AppBreakpoints.isMobile(width)) {
      return _buildTablet(l10n);
    }
    return _buildMobile(l10n);
  }

  Widget _buildDesktop(AppLocalizations l10n) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(l10n),
          const SizedBox(width: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildTablet(AppLocalizations l10n) {
    return Scaffold(
      body: Row(
        children: [
          _buildRail(l10n),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildRail(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      key: AppShell.navRailKey,
      width: 108,
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _buildLogo(size: 36),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                children: [
                  for (final section in NavSection.values)
                    _buildRailItem(section),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRailItem(NavSection section) {
    final config = context.styleConfig;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final selected = section == _current;

    return Material(
      key: AppShell.navTile(section),
      color: selected ? scheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(config.navIndicatorRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _select(section),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: [
              Icon(
                section.icon(selected: selected),
                size: 22,
                color: selected
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                section.label(l10n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobile(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            key: AppShell.openMenuKey,
            icon: const Icon(Icons.menu),
            tooltip: l10n.openNavigation,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(_current.label(l10n)),
        actions: [
          if (_current != NavSection.settings)
            IconButton(
              key: AppShell.quickSettingsKey,
              icon: const Icon(Icons.settings_outlined),
              tooltip: l10n.navSettings,
              onPressed: () => _select(NavSection.settings),
            ),
        ],
      ),
      drawer: _buildDrawer(l10n),
      body: _buildBody(),
    );
  }

  Widget _buildSidebar(AppLocalizations l10n) {
    final config = context.styleConfig;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: AppShell.sidebarKey,
      width: config.sidebarWidth,
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBrand(l10n),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                children: [
                  for (final section in NavSection.values) ...[
                    if (section == NavSection.settings) ...[
                      const SizedBox(height: AppSpacing.sm),
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    _buildNavTile(section),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(
      key: AppShell.drawerKey,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBrand(l10n),
            const Divider(),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                children: [
                  for (final section in NavSection.values)
                    _buildNavTile(
                      section,
                      onTapOverride: () => _selectFromDrawer(section),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          _buildLogo(size: 40),
          const SizedBox(width: 12),
          Text(
            l10n.appTitle,
            style: theme.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildLogo({required double size}) {
    final config = context.styleConfig;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(config.cardRadius * 0.5),
      ),
      child: Icon(
        Icons.dialpad,
        size: size * 0.55,
        color: scheme.onPrimary,
      ),
    );
  }

  Widget _buildNavTile(
    NavSection section, {
    VoidCallback? onTapOverride,
  }) {
    final config = context.styleConfig;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final selected = section == _current;

    return Material(
      key: AppShell.navTile(section),
      color: selected ? scheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(config.navIndicatorRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTapOverride ?? () => _select(section),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                section.icon(selected: selected),
                size: 22,
                color:
                    selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.label(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
