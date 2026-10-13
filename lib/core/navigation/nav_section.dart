import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

enum NavSection {
  dashboard,
  products,
  categories,
  orders,
  customers,
  resources,
  forms,
  pages,
  store,
  settings;

  String label(AppLocalizations l10n) => switch (this) {
        NavSection.dashboard => l10n.navDashboard,
        NavSection.products => l10n.navProducts,
        NavSection.categories => l10n.navCategories,
        NavSection.orders => l10n.navOrders,
        NavSection.customers => l10n.navCustomers,
        NavSection.resources => l10n.navResources,
        NavSection.forms => l10n.navForms,
        NavSection.pages => l10n.navPages,
        NavSection.store => l10n.navStore,
        NavSection.settings => l10n.navSettings,
      };

  IconData icon({required bool selected}) => switch (this) {
        NavSection.dashboard =>
          selected ? Icons.dashboard : Icons.dashboard_outlined,
        NavSection.products =>
          selected ? Icons.inventory_2 : Icons.inventory_2_outlined,
        NavSection.categories =>
          selected ? Icons.category : Icons.category_outlined,
        NavSection.orders =>
          selected ? Icons.receipt_long : Icons.receipt_long_outlined,
        NavSection.customers =>
          selected ? Icons.people : Icons.people_outline,
        NavSection.resources =>
          selected ? Icons.folder_copy : Icons.folder_copy_outlined,
        NavSection.forms =>
          selected ? Icons.assignment : Icons.assignment_outlined,
        NavSection.pages =>
          selected ? Icons.description : Icons.description_outlined,
        NavSection.store =>
          selected ? Icons.storefront : Icons.storefront_outlined,
        NavSection.settings =>
          selected ? Icons.settings : Icons.settings_outlined,
      };

  String get phase => switch (this) {
        NavSection.dashboard => '1',
        NavSection.products => '2',
        NavSection.categories => '2',
        NavSection.orders => '6',
        NavSection.customers => '6',
        NavSection.resources => '7',
        NavSection.forms => '8',
        NavSection.pages => '9',
        NavSection.store => '5',
        NavSection.settings => '1',
      };

  /// URL-safe segment used in the admin route (`/admin/<slug>`).
  String get slug => name;

  /// Absolute admin route for this section.
  String get location => '/admin/$slug';

  /// Resolves a [slug] back to a section, or `null` when unknown.
  static NavSection? fromSlug(String? slug) {
    if (slug == null) return null;
    for (final section in NavSection.values) {
      if (section.slug == slug) return section;
    }
    return null;
  }
}
