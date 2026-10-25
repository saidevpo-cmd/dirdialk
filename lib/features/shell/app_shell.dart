import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/app_spacing.dart';
import '../../core/design_system/app_style.dart';
import '../../core/navigation/nav_section.dart';
import '../../l10n/generated/app_localizations.dart';

/// Responsive admin shell (sidebar / rail / drawer) that hosts the currently
/// routed section as [child].
///
/// Navigation is delegated to go_router: selecting a section navigates to
/// `/admin/<slug>` and the router rebuilds this shell with the new section.
///
/// The shell also owns two navigation affordances:
///   * a **back-to-top** button that appears once the routed page has been
///     scrolled past [_backToTopThreshold]. Pages are hosted inside a
///     [PrimaryScrollController] so their top-level scroll view attaches to
///     the shell automatically — no page has to opt in.
///   * a **hide/show sidebar** button on desktop and tablet. The persistent
///     side navigation collapses with an [AnimatedSize] and the body expands
///     to fill the freed width. On mobile the same toggle is the existing
///     drawer menu button.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.currentSection,
    required this.child,
  });

  final NavSection currentSection;
  final Widget child;

  static const sidebarKey = Key('app-sidebar');
  static const drawerKey = Key('app-drawer');
  static const navRailKey = Key('app-nav-rail');
  static const bodyKey = Key('app-body');
  static const openMenuKey = Key('open-navigation');
  static const quickSettingsKey = Key('quick-settings');
  static const headerKey = Key('app-header');
  static const sidebarToggleKey = Key('toggle-sidebar');
  static const backToTopKey = Key('back-to-top');

  static Key navTile(NavSection section) => ValueKey('nav-${section.name}');

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// Scroll offset from which "back to top" becomes useful. Roughly one
  /// small viewport worth of content on phone, a nudge on desktop.
  static const double _backToTopThreshold = 300;
  static const Duration _scrollDuration = Duration(milliseconds: 350);
  static const Duration _resizeDuration = Duration(milliseconds: 220);

  final ScrollController _bodyScroll = ScrollController();

  /// Whether the persistent side navigation (sidebar on desktop, rail on
  /// tablet) is expanded. It starts expanded — hiding is opt-in, so the
  /// first-run layout is unchanged.
  bool _sideNavVisible = true;
  bool _showBackToTop = false;

  NavSection get _current => widget.currentSection;

  @override
  void initState() {
    super.initState();
    _bodyScroll.addListener(_syncBackToTop);
  }

  @override
  void dispose() {
    _bodyScroll.removeListener(_syncBackToTop);
    _bodyScroll.dispose();
    super.dispose();
  }

  void _syncBackToTop() {
    final show =
        _bodyScroll.hasClients && _bodyScroll.offset > _backToTopThreshold;
    if (show == _showBackToTop || !mounted) return;
    setState(() => _showBackToTop = show);
  }

  Future<void> _scrollToTop() async {
    if (!_bodyScroll.hasClients) return;
    await _bodyScroll.animateTo(
      0,
      duration: _scrollDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleSideNav() => setState(() => _sideNavVisible = !_sideNavVisible);

  void _select(NavSection section) {
    if (section == _current) return;
    context.go(section.location);
  }

  void _selectFromDrawer(NavSection section) {
    Navigator.of(context).pop();
    _select(section);
  }

  Widget _buildBody() => KeyedSubtree(
        key: AppShell.bodyKey,
        child: PrimaryScrollController(
          controller: _bodyScroll,
          // Desktop and web do not inherit a primary controller by default;
          // opting in on every platform is what lets one button scroll any
          // routed page back to the top.
          automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
          child: widget.child,
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
      body: Column(
        children: [
          _buildHeader(l10n),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                _buildAnimatedSideNav(_buildSidebar(l10n)),
                const SizedBox(width: 1),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablet(AppLocalizations l10n) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(l10n),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                _buildAnimatedSideNav(_buildRail(l10n)),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Wraps the persistent side navigation so it can collapse and expand
  /// smoothly; the [Expanded] body next to it reflows at the same time.
  Widget _buildAnimatedSideNav(Widget child) {
    return AnimatedSize(
      duration: _resizeDuration,
      curve: Curves.easeInOut,
      alignment: AlignmentDirectional.centerStart,
      child: _sideNavVisible ? child : const SizedBox(width: 0, height: 0),
    );
  }

  /// Desktop / tablet top bar carrying the sidebar toggle and, once the page
  /// is scrolled, the back-to-top button.
  Widget _buildHeader(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      key: AppShell.headerKey,
      color: scheme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              IconButton(
                key: AppShell.sidebarToggleKey,
                tooltip: _sideNavVisible ? l10n.hideSidebar : l10n.showSidebar,
                icon: Icon(_sideNavVisible ? Icons.menu_open : Icons.menu),
                onPressed: _toggleSideNav,
              ),
              _buildBackToTopButton(),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _current.label(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (_current != NavSection.settings)
                IconButton(
                  key: AppShell.quickSettingsKey,
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: l10n.navSettings,
                  onPressed: () => _select(NavSection.settings),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fades and slides into place only once the page is scrolled down, so the
  /// top bar stays clean on first load.
  Widget _buildBackToTopButton() {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedSize(
      duration: _resizeDuration,
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        key: AppShell.backToTopKey,
        opacity: _showBackToTop ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: IgnorePointer(
          ignoring: !_showBackToTop,
          child: IconButton(
            tooltip: l10n.backToTop,
            icon: const Icon(Icons.arrow_upward),
            onPressed: _scrollToTop,
          ),
        ),
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
          _buildBackToTopButton(),
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
