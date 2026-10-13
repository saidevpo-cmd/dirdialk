import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../core/navigation/nav_section.dart';
import '../core/settings/settings_controller.dart';
import '../features/auth/login_page.dart';
import '../features/categories/categories_page.dart';
import '../features/customers/customers_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/forms/forms_page.dart';
import '../features/orders/orders_page.dart';
import '../features/pages/pages_page.dart';
import '../features/products/products_page.dart';
import '../features/resources/resources_page.dart';
import '../features/settings/settings_page.dart';
import '../features/shell/app_shell.dart';
import '../features/store/store_page.dart';

/// Application router.
///
/// Routes:
/// - `/login` — admin sign-in (only reachable when authentication is required)
/// - `/admin/<section>` — the admin shell with one section per [NavSection]
///
/// When no backend is configured the redirect gate is disabled and `/admin`
/// opens directly, preserving the offline local-first behaviour.
class AppRouter {
  AppRouter({required this.settings, required this.auth});

  final SettingsController settings;
  final AuthController auth;

  static const String loginPath = '/login';
  static const String adminPath = '/admin';

  static String sectionPath(NavSection section) => section.location;

  late final GoRouter router = GoRouter(
    initialLocation: adminPath,
    refreshListenable: auth,
    redirect: (context, state) {
      final location = state.matchedLocation;

      // Normalize the bare admin path to the dashboard section.
      if (location == adminPath) {
        return sectionPath(NavSection.dashboard);
      }

      final isLogin = location == loginPath;

      // Offline/local mode: no gate. Login is never shown.
      if (!auth.requireAuth) {
        return isLogin ? sectionPath(NavSection.dashboard) : null;
      }

      // A backend is configured: a session is required.
      if (!auth.isAuthenticated) {
        return isLogin ? null : loginPath;
      }
      if (isLogin) {
        return sectionPath(NavSection.dashboard);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: loginPath,
        builder: (context, state) => LoginPage(auth: auth),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final section = state.uri.pathSegments.length > 1
              ? NavSection.fromSlug(state.uri.pathSegments[1])
              : null;
          return AppShell(
            currentSection: section ?? NavSection.dashboard,
            child: child,
          );
        },
        routes: [
          for (final section in NavSection.values)
            GoRoute(
              path: sectionPath(section),
              builder: (context, state) => _pageFor(section, context),
            ),
        ],
      ),
    ],
  );

  Widget _pageFor(NavSection section, BuildContext context) {
    void go(NavSection target) => context.go(sectionPath(target));
    return switch (section) {
      NavSection.dashboard => DashboardPage(onNavigate: go),
      NavSection.products => const ProductsPage(),
      NavSection.categories => const CategoriesPage(),
      NavSection.orders => const OrdersPage(),
      NavSection.customers => const CustomersPage(),
      NavSection.resources => const ResourcesPage(),
      NavSection.forms => const FormsPage(),
      NavSection.pages => const PagesPage(),
      NavSection.store => const StorePage(),
      NavSection.settings => SettingsPage(settings: settings, auth: auth),
    };
  }
}
