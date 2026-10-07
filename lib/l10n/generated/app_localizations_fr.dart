// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'diali';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navProducts => 'Produits';

  @override
  String get navOrders => 'Commandes';

  @override
  String get navCustomers => 'Clients';

  @override
  String get navResources => 'Ressources';

  @override
  String get navForms => 'Formulaires';

  @override
  String get navPages => 'Pages';

  @override
  String get navStore => 'Boutique';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get openNavigation => 'Ouvrir le menu de navigation';

  @override
  String get closeNavigation => 'Fermer le menu de navigation';

  @override
  String get dashboardSubtitle =>
      'Voici ce qui se passe dans votre activité aujourd\'hui.';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get viewAll => 'Tout afficher';

  @override
  String get statProducts => 'Total des produits';

  @override
  String get statOrders => 'Total des commandes';

  @override
  String get statCustomers => 'Total des clients';

  @override
  String get statResources => 'Total des ressources';

  @override
  String get statProductsTrend => '+12 % ce mois-ci';

  @override
  String get statOrdersTrend => '+8 % ce mois-ci';

  @override
  String get statCustomersTrend => '+5 % ce mois-ci';

  @override
  String get statResourcesTrend => '2 ajoutées cette semaine';

  @override
  String activityOrder(Object id) {
    return 'Nouvelle commande $id reçue';
  }

  @override
  String activityLowStock(Object name) {
    return 'Stock faible pour $name';
  }

  @override
  String activityCustomer(Object name) {
    return 'Nouveau client : $name';
  }

  @override
  String activityResource(Object name) {
    return '$name ajouté aux ressources';
  }

  @override
  String get timeToday => 'Aujourd\'hui';

  @override
  String get timeYesterday => 'Hier';

  @override
  String get actionAddProduct => 'Ajouter un produit';

  @override
  String get actionNewOrder => 'Nouvelle commande';

  @override
  String get actionAddCustomer => 'Ajouter un client';

  @override
  String get actionAddResource => 'Ajouter une ressource';

  @override
  String get actionComingSoon => 'Disponible dans une phase ultérieure';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSubtitle =>
      'Personnalisez la langue, l\'apparence et le style.';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageDescription => 'Choisissez la langue de l\'application.';

  @override
  String get appearanceTitle => 'Apparence';

  @override
  String get appearanceDescription =>
      'Choisissez le mode clair, sombre ou système.';

  @override
  String get modeSystem => 'Système';

  @override
  String get modeLight => 'Clair';

  @override
  String get modeDark => 'Sombre';

  @override
  String get styleTitle => 'Style';

  @override
  String get styleDescription =>
      'Changez le style visuel de toute l\'application.';

  @override
  String get styleModern => 'Moderne';

  @override
  String get styleMinimal => 'Minimal';

  @override
  String get styleProfessional => 'Professionnel';

  @override
  String get styleModernDesc => 'Arrondi, coloré et convivial.';

  @override
  String get styleMinimalDesc => 'Plat, net et calme.';

  @override
  String get styleProfessionalDesc => 'Compact, formel et dense.';

  @override
  String pagePhase(Object phase) {
    return 'Prévu pour la phase $phase.';
  }

  @override
  String get pageBadge => 'Bientôt disponible';
}
