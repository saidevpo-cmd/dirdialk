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
  String get navOrderHistory => 'Historique des commandes';

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
      'Voici l\'activité de votre entreprise aujourd\'hui.';

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
  String get statProductsTrend => '+12% ce mois-ci';

  @override
  String get statOrdersTrend => '+8% ce mois-ci';

  @override
  String get statCustomersTrend => '+5% ce mois-ci';

  @override
  String get statResourcesTrend => '2 ajoutés cette semaine';

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
  String get actionAddForm => 'Nouveau formulaire';

  @override
  String get actionAddPage => 'Nouvelle page';

  @override
  String get actionComingSoon => 'Disponible dans une phase ultérieure';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionCopy => 'Copier';

  @override
  String get actionCopied => 'Copié dans le presse-papiers.';

  @override
  String searchIn(Object section) {
    return 'Rechercher dans $section';
  }

  @override
  String emptySearch(Object query) {
    return 'Aucun résultat pour « $query ».';
  }

  @override
  String resultCount(Object count) {
    return '$count résultats';
  }

  @override
  String get productsSubtitle =>
      'Gérez votre catalogue, vos prix et vos niveaux de stock.';

  @override
  String get ordersSubtitle =>
      'Suivez chaque commande du paiement à la livraison.';

  @override
  String get customersSubtitle =>
      'Votre base de clients et l\'historique des achats.';

  @override
  String get resourcesSubtitle => 'Documents, médias et fichiers partagés.';

  @override
  String get formsSubtitle =>
      'Créez des formulaires et recueillez des soumissions.';

  @override
  String get pagesSubtitle => 'Créez et gérez les pages de votre plateforme.';

  @override
  String get storeSubtitle => 'Prévisualisez votre vitrine commerciale.';

  @override
  String get colName => 'Nom';

  @override
  String get colSku => 'UGS / SKU';

  @override
  String get colCategory => 'Catégorie';

  @override
  String get colPrice => 'Prix';

  @override
  String get colStock => 'Stock';

  @override
  String get colStatus => 'Statut';

  @override
  String get colOrder => 'Commande';

  @override
  String get colCustomer => 'Client';

  @override
  String get colDate => 'Date';

  @override
  String get colTotal => 'Total';

  @override
  String get colEmail => 'E-mail';

  @override
  String get colOrders => 'Commandes';

  @override
  String get colSpent => 'Total dépensé';

  @override
  String get colTier => 'Niveau';

  @override
  String get colType => 'Type';

  @override
  String get colSize => 'Taille';

  @override
  String get colUpdated => 'Mis à jour';

  @override
  String get colSubmissions => 'Soumissions';

  @override
  String get colTitle => 'Titre';

  @override
  String get colSlug => 'Slug';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusLow => 'Stock faible';

  @override
  String get statusPaid => 'Payé';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusShipped => 'Expédié';

  @override
  String get statusDelivered => 'Livré';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get statusDraft => 'Brouillon';

  @override
  String get statusPublished => 'Publié';

  @override
  String get statusNew => 'Nouveau';

  @override
  String get statusVip => 'VIP';

  @override
  String get statusRegular => 'Standard';

  @override
  String get typeDocument => 'Document';

  @override
  String get typeSpreadsheet => 'Feuille de calcul';

  @override
  String get typeImage => 'Image';

  @override
  String get typeFolder => 'Dossier';

  @override
  String get productsLowStockTitle => 'Stock faible';

  @override
  String productsLowStock(Object count) {
    return '$count en stock faible';
  }

  @override
  String get productsValueTitle => 'Valeur du stock';

  @override
  String get ordersPendingTitle => 'En attente';

  @override
  String ordersPending(Object count) {
    return '$count en attente';
  }

  @override
  String get ordersRevenueTitle => 'Chiffre d\'affaires';

  @override
  String get customersVipTitle => 'Clients VIP';

  @override
  String customersVip(Object count) {
    return '$count VIP';
  }

  @override
  String get customersValueTitle => 'Total des achats';

  @override
  String get resourcesUsedTitle => 'Stockage utilisé';

  @override
  String formsSubmissions(Object count) {
    return '$count soumissions';
  }

  @override
  String formsPublished(Object count) {
    return '$count publiés';
  }

  @override
  String pagesPublished(Object count) {
    return '$count publiées';
  }

  @override
  String pagesDraft(Object count) {
    return '$count brouillons';
  }

  @override
  String get storeOpen => 'Ouvrir la vitrine';

  @override
  String get storeBannerTitle => 'Nouvelle saison, nouveaux produits';

  @override
  String get storeBannerBody =>
      'Parcourez le catalogue de démonstration local.';

  @override
  String get storeBannerCta => 'Découvrir les produits';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String addedToCart(Object name) {
    return '$name a été ajouté à votre panier.';
  }

  @override
  String get storeCartTitle => 'Panier';

  @override
  String get cartEmpty => 'Votre panier est vide.';

  @override
  String storeCartItems(Object count) {
    return '$count articles dans le panier';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSubtitle => 'Langue, alertes, confidentialité et données.';

  @override
  String get settingsSearchHint => 'Rechercher dans les paramètres';

  @override
  String settingsNoResults(Object query) {
    return 'Aucun paramètre ne correspond à « $query ».';
  }

  @override
  String get sectionGeneral => 'Général';

  @override
  String get sectionGeneralDesc => 'Langue, apparence et style visuel.';

  @override
  String get sectionNotifications => 'Notifications';

  @override
  String get sectionNotificationsDesc =>
      'Choisissez les alertes que vous souhaitez recevoir.';

  @override
  String get sectionPrivacy => 'Confidentialité et politique';

  @override
  String get sectionPrivacyDesc =>
      'Préférences de données, politique de confidentialité et conditions.';

  @override
  String get sectionData => 'Données et stockage';

  @override
  String get sectionDataDesc =>
      'Exportation, réinitialisation et stockage local.';

  @override
  String get sectionAbout => 'À propos';

  @override
  String get sectionAboutDesc => 'Version, licences et contact.';

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
  String get styleMinimal => 'Minimaliste';

  @override
  String get styleProfessional => 'Professionnel';

  @override
  String get styleModernDesc => 'Arrondi, coloré et convivial.';

  @override
  String get styleMinimalDesc => 'Épuré, sobre et calme.';

  @override
  String get styleProfessionalDesc => 'Compact, formel et dense.';

  @override
  String get notifOrders => 'Nouvelles commandes';

  @override
  String get notifOrdersDesc =>
      'Être notifié lorsqu\'une nouvelle commande arrive.';

  @override
  String get notifLowStock => 'Alertes de stock faible';

  @override
  String get notifLowStockDesc =>
      'M\'avertir lorsqu\'un produit est presque épuisé.';

  @override
  String get notifWeekly => 'Résumé hebdomadaire';

  @override
  String get notifWeeklyDesc => 'Un récapitulatif de l\'activité chaque lundi.';

  @override
  String get privacyAnalytics => 'Statistiques anonymes';

  @override
  String get privacyAnalyticsDesc =>
      'Partager des statistiques d\'usage pour améliorer l\'application.';

  @override
  String get privacyCrash => 'Rapports de plantage';

  @override
  String get privacyCrashDesc =>
      'Envoyer des diagnostics lorsqu\'un problème survient.';

  @override
  String get privacyPersonalization => 'Personnalisation';

  @override
  String get privacyPersonalizationDesc =>
      'Mémoriser les préférences sur cet appareil.';

  @override
  String get privacyPolicyAction => 'Lire la politique de confidentialité';

  @override
  String get privacyPolicyActionDesc =>
      'Comment vos données sont stockées et protégées.';

  @override
  String get termsAction => 'Lire les conditions d\'utilisation';

  @override
  String get termsActionDesc =>
      'Les règles applicables à l\'utilisation de diali.';

  @override
  String get consentTitle => 'Consentement aux politiques';

  @override
  String consentAccepted(Object date) {
    return 'Accepté le $date.';
  }

  @override
  String get consentPending =>
      'La politique actuelle n\'a pas encore été acceptée.';

  @override
  String get consentAction => 'Consulter et accepter';

  @override
  String get consentUpdated => 'Politique mise à jour';

  @override
  String get consentAcceptedToast =>
      'Merci — votre consentement a été enregistré.';

  @override
  String get policyAccept => 'Accepter la politique';

  @override
  String get policyNotNow => 'Pas maintenant';

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get privacyIntro => 'diali fonctionne entièrement sur votre appareil.';

  @override
  String get privacyIntroTitle => 'Aperçu';

  @override
  String get privacyCollectTitle => 'Données stockées sur votre appareil';

  @override
  String get privacyCollectBody =>
      'Les préférences sont stockées dans la base de données locale.';

  @override
  String get privacyOptionalTitle => 'Données optionnelles';

  @override
  String get privacyOptionalBody =>
      'Les statistiques anonymes sont désactivées par défaut.';

  @override
  String get privacyLocalTitle => 'Stockage local uniquement';

  @override
  String get privacyLocalBody =>
      'L\'application utilise uniquement le stockage local de cet appareil.';

  @override
  String get privacyRightsTitle => 'Vos droits';

  @override
  String get privacyRightsBody =>
      'Vous pouvez modifier ou supprimer vos préférences à tout moment.';

  @override
  String get privacyContactTitle => 'Contact';

  @override
  String privacyContactBody(Object email) {
    return 'Des questions sur cette politique ? Écrivez à $email.';
  }

  @override
  String privacyUpdatedOn(Object date) {
    return 'Dernière mise à jour : $date';
  }

  @override
  String get privacyUpdatedTitle => 'Dernière mise à jour';

  @override
  String get termsTitle => 'Conditions d\'utilisation';

  @override
  String get termsAcceptTitle => 'Acceptation';

  @override
  String get termsAcceptBody =>
      'En utilisant diali, vous acceptez ces conditions.';

  @override
  String get termsUseTitle => 'Utilisation autorisée';

  @override
  String get termsUseBody =>
      'L\'application est fournie pour gérer vos propres données commerciales.';

  @override
  String get termsAvailabilityTitle => 'Disponibilité';

  @override
  String get termsAvailabilityBody =>
      'Cette version est une application de base locale.';

  @override
  String get termsLiabilityTitle => 'Responsabilité';

  @override
  String get termsLiabilityBody =>
      'L\'application est fournie telle quelle, sans garantie.';

  @override
  String get termsChangesTitle => 'Modifications';

  @override
  String get termsChangesBody => 'Nous pouvons mettre à jour ces conditions.';

  @override
  String get termsContactTitle => 'Contact';

  @override
  String termsContactBody(Object email) {
    return 'Des questions sur ces conditions ? Écrivez à $email.';
  }

  @override
  String get dataStorage => 'Stockage local';

  @override
  String get dataStorageDesc =>
      'Les préférences sont sauvegardées sur cet appareil uniquement.';

  @override
  String get dataExport => 'Exporter les paramètres';

  @override
  String get dataExportDesc =>
      'Télécharger vos préférences sous forme de fichier JSON.';

  @override
  String get dataExportTitle => 'Vos paramètres';

  @override
  String get dataReset => 'Réinitialiser tous les paramètres';

  @override
  String get dataResetDesc =>
      'Restaurer la langue, l\'apparence et le style par défaut.';

  @override
  String get dataResetTitle => 'Réinitialiser tous les paramètres ?';

  @override
  String get dataResetBody => 'Cette action est irréversible.';

  @override
  String get dataResetConfirm => 'Réinitialiser';

  @override
  String get aboutVersion => 'Version de l\'application';

  @override
  String get aboutBuild => 'Numéro de build';

  @override
  String get aboutLicenses => 'Licences open source';

  @override
  String get aboutLicensesDesc => 'Licences des paquets utilisés par diali.';

  @override
  String get aboutContact => 'Contact';

  @override
  String get aboutContactDesc => 'Questions, commentaires et support.';

  @override
  String get aboutOffline => 'Fonctionne hors ligne';

  @override
  String get aboutOfflineDesc =>
      'diali fonctionne entièrement sans connexion Internet.';

  @override
  String get navCategories => 'Catégories';

  @override
  String get dashboardRecentOrders => 'Commandes récentes';

  @override
  String get dashboardRecentProducts => 'Produits récents';

  @override
  String get dashboardLatestArticles => 'Derniers articles';

  @override
  String get dashboardRecentDirectory => 'Ressources du répertoire';

  @override
  String get dashboardNoOrders =>
      'Aucune commande. Les commandes de la boutique apparaîtront ici.';

  @override
  String get dashboardNoProducts =>
      'Aucun produit. Ajoutez votre premier produit.';

  @override
  String get dashboardNoArticles => 'Aucun article.';

  @override
  String get dashboardNoDirectory => 'Aucune ressource dans le répertoire.';

  @override
  String get dashboardInventoryValue => 'Valeur du stock';

  @override
  String get dashboardTotalCategories => 'Catégories';

  @override
  String get dashboardRevenue => 'Chiffre d\'affaires';

  @override
  String get dashboardPublishedArticles => 'Articles publiés';

  @override
  String get categoriesSubtitle =>
      'Organisez votre catalogue avec des catégories réutilisables.';

  @override
  String get addCategory => 'Ajouter une catégorie';

  @override
  String get editCategory => 'Modifier la catégorie';

  @override
  String get categoryName => 'Nom de la catégorie';

  @override
  String get categorySlug => 'Slug';

  @override
  String get categoryDescription => 'Description';

  @override
  String get categoryNameRequired => 'Le nom de la catégorie est obligatoire.';

  @override
  String get categoryNameExists => 'Une catégorie avec ce nom existe déjà.';

  @override
  String get categoryCreated => 'Catégorie créée.';

  @override
  String get categoryUpdated => 'Catégorie mise à jour.';

  @override
  String get categoryDeleted => 'Catégorie supprimée.';

  @override
  String get deleteCategoryTitle => 'Supprimer la catégorie ?';

  @override
  String deleteCategoryBody(Object name) {
    return 'Voulez-vous vraiment supprimer « $name » ?';
  }

  @override
  String deleteCategoryInUse(Object count) {
    return '$count produit(s) utilisent cette catégorie. Ils seront déplacés vers Non classé.';
  }

  @override
  String get uncategorized => 'Non classé';

  @override
  String get storeProfileTitle => 'Profil de la boutique';

  @override
  String get storeProfileDescription => 'Nom public, identité et coordonnées.';

  @override
  String get storeName => 'Nom de la boutique';

  @override
  String get storeDescriptionLabel => 'Description de la boutique';

  @override
  String get storeLogoUrl => 'URL du logo';

  @override
  String get storeContactEmail => 'E-mail de contact';

  @override
  String get storeContactPhone => 'Téléphone';

  @override
  String get storeAddress => 'Adresse';

  @override
  String get storefrontTemplate => 'Modèle de vitrine';

  @override
  String get storefrontTemplateDesc =>
      'Design client : moderne, minimal ou professionnel.';

  @override
  String get templateModern => 'Moderne';

  @override
  String get templateMinimal => 'Minimal';

  @override
  String get templateProfessional => 'Professionnel';

  @override
  String get saved => 'Enregistré.';

  @override
  String get demoDataTitle => 'Données de démonstration';

  @override
  String get demoDataDesc =>
      'Charger des produits et catégories d\'exemple avec des images locales.';

  @override
  String get demoDataAction => 'Charger les données démo';

  @override
  String get demoDataLoading => 'Chargement des données démo…';

  @override
  String demoDataResult(Object categories, Object products) {
    return '$products produits et $categories catégories ajoutés.';
  }

  @override
  String get demoDataAlready => 'Les données démo sont déjà chargées.';

  @override
  String get demoDataFailed => 'Impossible de charger les données démo.';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginSubtitle => 'Connectez-vous pour gérer votre activité.';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginEmailHint => 'you@example.com';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginSubmit => 'Se connecter';

  @override
  String get loginEmailRequired => 'Saisissez votre adresse e-mail.';

  @override
  String get loginEmailInvalid => 'Saisissez une adresse e-mail valide.';

  @override
  String get loginPasswordRequired => 'Saisissez votre mot de passe.';

  @override
  String get loginFailed =>
      'Échec de la connexion. Vérifiez vos identifiants et réessayez.';

  @override
  String get loginOfflineNotice =>
      'Mode hors ligne — aucune connexion requise.';

  @override
  String get accountTitle => 'Compte';

  @override
  String get accountDescription => 'Connexion et session.';

  @override
  String accountSignedInAs(String email) {
    return 'Connecté en tant que $email';
  }

  @override
  String get accountLocalMode => 'Mode hors ligne — aucun compte requis.';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutConfirmTitle => 'Se déconnecter ?';

  @override
  String get signOutConfirmBody =>
      'Vous devrez vous reconnecter pour accéder au tableau de bord.';

  @override
  String get signOutConfirm => 'Se déconnecter';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionCreate => 'Créer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionView => 'Voir';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionRemove => 'Retirer';

  @override
  String get actionSaveChanges => 'Enregistrer les modifications';

  @override
  String get actionClear => 'Effacer';

  @override
  String get errorTitle => 'Une erreur s\'est produite';

  @override
  String get noRecordsTitle => 'Aucun enregistrement';

  @override
  String get searchDefaultHint => 'Rechercher...';

  @override
  String get loadFailed => 'Impossible de charger les données. Réessayez.';

  @override
  String get fieldRequired => 'Ce champ est obligatoire.';

  @override
  String get changesSaved => 'Modifications enregistrées.';

  @override
  String get recordCreated => 'Créé avec succès.';

  @override
  String get recordUpdated => 'Mis à jour avec succès.';

  @override
  String get recordDeleted => 'Supprimé avec succès.';

  @override
  String get operationFailed => 'L\'opération n\'a pas pu être effectuée.';

  @override
  String deleteDialogTitle(Object name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get deleteDialogBody => 'Cette action est irréversible.';

  @override
  String get guestLabel => 'Invité';

  @override
  String get subtotalLabel => 'Sous-total';

  @override
  String get taxLabel => 'Taxe';

  @override
  String get shippingLabel => 'Livraison';

  @override
  String get totalAmountLabel => 'Montant total';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get allStatuses => 'Tous les statuts';

  @override
  String get allTiers => 'Tous les niveaux';

  @override
  String get colProduct => 'Produit';

  @override
  String get colContact => 'Contact';

  @override
  String get colLocation => 'Emplacement';

  @override
  String get colDetails => 'Détails';

  @override
  String get colItems => 'Articles';

  @override
  String get colActions => 'Actions';

  @override
  String get statusArchived => 'Archivé';

  @override
  String get statusHidden => 'Masqué';

  @override
  String get statActive => 'Actifs';

  @override
  String get statLowStock => 'Stock faible';

  @override
  String get statOutOfStock => 'Rupture de stock';

  @override
  String itemCount(Object count) {
    return '$count articles';
  }

  @override
  String get productDetailsTitle => 'Détails du produit';

  @override
  String get demoPrice => 'Prix démo';

  @override
  String get inStock => 'En stock';

  @override
  String get outOfStock => 'Rupture de stock';

  @override
  String get lowStock => 'Stock faible';

  @override
  String get searchProductsHint => 'Rechercher par nom ou SKU...';

  @override
  String get productsEmptyTitle => 'Aucun produit trouvé';

  @override
  String get productsEmptyMessage =>
      'Ajustez votre recherche ou ajoutez un produit.';

  @override
  String get productCreated => 'Produit créé.';

  @override
  String get productUpdated => 'Produit mis à jour.';

  @override
  String get productDeleted => 'Produit supprimé.';

  @override
  String get deleteProductTitle => 'Supprimer le produit ?';

  @override
  String deleteProductBody(Object name) {
    return 'Supprimer « $name » ? Cette action est irréversible.';
  }

  @override
  String stockUnits(Object count) {
    return '$count en stock';
  }

  @override
  String get lowBadge => 'Faible';

  @override
  String get editProductTitle => 'Modifier le produit';

  @override
  String get productNameLabel => 'Nom du produit';

  @override
  String get productPriceLabel => 'Prix';

  @override
  String get productCostLabel => 'Coût';

  @override
  String get productStockLabel => 'Quantité en stock';

  @override
  String get productStatusLabel => 'Statut';

  @override
  String get productDescriptionLabel => 'Description';

  @override
  String get productNameRequired => 'Le nom du produit est obligatoire.';

  @override
  String get searchOrdersHint =>
      'Rechercher par numéro de commande ou client...';

  @override
  String get orderHistorySubtitle =>
      'Retrouvez, consultez et réimprimez toute commande passée.';

  @override
  String get searchHistoryHint =>
      'Rechercher par numéro de commande ou client...';

  @override
  String get orderDateLabel => 'Date de la commande';

  @override
  String get dateRangeFilter => 'Période';

  @override
  String get clearDateFilter => 'Effacer la période';

  @override
  String get colQty => 'Qté';

  @override
  String get unitPriceLabel => 'Prix unitaire';

  @override
  String get discountLabel => 'Remise';

  @override
  String get notesLabel => 'Remarques';

  @override
  String get historyEmptyTitle => 'Aucune commande ne correspond aux filtres';

  @override
  String get historyEmptyMessage =>
      'Essayez d\'ajuster la recherche, la période ou le filtre de statut.';

  @override
  String get printOrder => 'Imprimer la commande';

  @override
  String get downloadPdf => 'Télécharger le PDF';

  @override
  String get printDocumentFailed =>
      'Impossible de préparer le document d\'impression. Veuillez réessayer.';

  @override
  String get orderDocumentTitle => 'Reçu de commande';

  @override
  String reprintFooter(Object date) {
    return 'Réimprimé le $date à partir des données originales de la commande.';
  }

  @override
  String get customerInformation => 'Informations client';

  @override
  String get nameLabel => 'Nom';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get addressLabel => 'Adresse';

  @override
  String get updateStatusTitle => 'Mettre à jour le statut';

  @override
  String get markPaid => 'Marquer comme payée';

  @override
  String get markShipped => 'Marquer comme expédiée';

  @override
  String get markDelivered => 'Marquer comme livrée';

  @override
  String get cancelOrder => 'Annuler la commande';

  @override
  String get cancelOrderTitle => 'Annuler cette commande ?';

  @override
  String get cancelOrderBody => 'La commande sera marquée comme annulée.';

  @override
  String get ordersEmptyTitle => 'Aucune commande trouvée';

  @override
  String get ordersEmptyMessage =>
      'Effacez les filtres ou les termes de recherche.';

  @override
  String get orderStatusUpdated => 'Statut de la commande mis à jour.';

  @override
  String orderLabel(Object number) {
    return 'Commande $number';
  }

  @override
  String get editCustomerTitle => 'Modifier le client';

  @override
  String get customerNameLabel => 'Nom complet';

  @override
  String get customerPhoneLabel => 'Téléphone';

  @override
  String get customerCityLabel => 'Ville';

  @override
  String get customerCountryLabel => 'Pays';

  @override
  String get customerAddressLabel => 'Adresse';

  @override
  String get customerTierLabel => 'Niveau du client';

  @override
  String get customerNotesLabel => 'Notes internes';

  @override
  String get searchCustomersHint =>
      'Rechercher par nom, e-mail, téléphone ou ville...';

  @override
  String get customersEmptyTitle => 'Aucun client trouvé';

  @override
  String get customersEmptyMessage =>
      'Ajoutez un nouveau client pour commencer.';

  @override
  String get customerCreated => 'Client créé.';

  @override
  String get customerUpdated => 'Client mis à jour.';

  @override
  String get customerDeleted => 'Client supprimé.';

  @override
  String get deleteCustomerTitle => 'Supprimer le client ?';

  @override
  String get spentLabel => 'Dépensé';

  @override
  String get statVipClients => 'Clients VIP';

  @override
  String get statLifetimeValue => 'Valeur totale';

  @override
  String get storefrontTitle => 'Boutique';

  @override
  String get shopByCategory => 'Acheter par catégorie';

  @override
  String get featuredProducts => 'Produits en vedette';

  @override
  String get latestProducts => 'Derniers produits';

  @override
  String get allProducts => 'Tous les produits';

  @override
  String get cartTitle => 'Panier';

  @override
  String get cartEmptyMessage => 'Votre panier est vide.';

  @override
  String get checkoutAction => 'Commander';

  @override
  String orderPlaced(Object number) {
    return 'Commande $number passée avec succès.';
  }

  @override
  String get orderFailed => 'Impossible de passer la commande.';

  @override
  String get estimatedTax => 'Taxe estimée';

  @override
  String get storefrontSubtitle =>
      'Parcourez les produits et prévisualisez l\'expérience client en ligne.';

  @override
  String productsInCategory(Object category) {
    return 'Produits dans $category';
  }

  @override
  String get noProductsInCategoryTitle => 'Aucun produit dans cette catégorie';

  @override
  String get noProductsInCategoryMessage => 'Essayez une autre catégorie.';

  @override
  String get generalLabel => 'Général';

  @override
  String get eachLabel => 'l\'unité';

  @override
  String get bannerNewArrivals => 'Nouveautés';

  @override
  String get bannerLocalDelivery => 'Livraison locale';

  @override
  String get bannerStorePickup => 'Retrait en magasin';

  @override
  String get storeCustomerName => 'Client de la boutique';

  @override
  String get storeOrderNote => 'Commande en ligne';

  @override
  String get removeFromCart => 'Retirer du panier';

  @override
  String get increaseQuantity => 'Augmenter la quantité';

  @override
  String get decreaseQuantity => 'Diminuer la quantité';

  @override
  String get catRoot => 'Catégories principales';

  @override
  String get catSub => 'Sous-catégories';

  @override
  String get catShopBy => 'Acheter par catégorie';

  @override
  String get catTapHint => 'Touchez une catégorie pour voir ses produits.';

  @override
  String get catSearchHint => 'Rechercher des catégories...';

  @override
  String get catNoProducts => 'Aucun produit dans cette catégorie';

  @override
  String catNoProductsHint(Object category) {
    return 'Ajoutez des produits et affectez-les à $category.';
  }

  @override
  String catProductCount(Object count) {
    return '$count produits';
  }

  @override
  String get categoriesEmptyTitle => 'Aucune catégorie';

  @override
  String get categoriesEmptyMessage =>
      'Créez votre première catégorie pour organiser les produits.';

  @override
  String get colProducts => 'Produits';

  @override
  String get colDescription => 'Description';

  @override
  String get productImagesLabel => 'Images du produit';

  @override
  String get productImagesHint =>
      'Résolution recommandée 800 × 1000 (4:5). La première image est l\'image principale.';

  @override
  String get imageMainBadge => 'Principale';

  @override
  String get imageSetMain => 'Définir comme principale';

  @override
  String get imageReplace => 'Remplacer';

  @override
  String get imageMoveBackward => 'Déplacer à gauche';

  @override
  String get imageMoveForward => 'Déplacer à droite';

  @override
  String get imageAdd => 'Ajouter une image';

  @override
  String get imageOptions => 'Options de l\'image';

  @override
  String get removeImageTitle => 'Retirer cette image ?';

  @override
  String get removeImageBody =>
      'L\'image sera retirée du produit. Cette action est irréversible.';

  @override
  String get imageRemoved => 'Image retirée.';

  @override
  String get noImage => 'Aucune image';

  @override
  String get categoryImageLabel => 'Image de la catégorie';

  @override
  String get categoryImageHint => 'Résolution recommandée 600 × 600 (1:1).';

  @override
  String get selectImage => 'Choisir une image';

  @override
  String get removeCategoryImageBody =>
      'L\'image sera retirée de la catégorie. Cette action est irréversible.';

  @override
  String imageCounter(Object current, Object total) {
    return '$current / $total';
  }

  @override
  String get checkoutNameTooShort =>
      'Veuillez saisir le nom complet du client.';

  @override
  String get checkoutPhoneInvalid =>
      'Saisissez un numéro de téléphone valide (7-15 chiffres).';

  @override
  String get checkoutQuantityInvalid => 'La quantité doit être d\'au moins 1.';

  @override
  String checkoutInsufficientStock(Object available, Object product) {
    return 'Il ne reste que $available de $product.';
  }

  @override
  String get checkoutAddressTooLong =>
      'L\'adresse est trop longue (300 caractères max).';

  @override
  String get checkoutCityTooLong =>
      'Le nom de la ville est trop long (120 caractères max).';

  @override
  String get businessLocation => 'Localisation de l\'entreprise';

  @override
  String get businessLocationHint =>
      'Affichée sur la carte de la boutique et utilisée pour l\'itinéraire.';

  @override
  String get latitudeLabel => 'Latitude';

  @override
  String get longitudeLabel => 'Longitude';

  @override
  String get useCurrentLocation => 'Utiliser la position actuelle';

  @override
  String get locationPermissionDenied =>
      'L\'autorisation de localisation a été refusée.';

  @override
  String get locationServicesDisabled =>
      'Les services de localisation sont désactivés.';

  @override
  String get locationUnavailable => 'Impossible de déterminer votre position.';

  @override
  String get locationInvalid =>
      'Saisissez une latitude entre -90 et 90 et une longitude entre -180 et 180.';

  @override
  String get openInMaps => 'Ouvrir dans les cartes';

  @override
  String get socialMedia => 'Réseaux sociaux';

  @override
  String get socialMediaHint =>
      'Ajoutez les liens de profil affichés sur la boutique.';

  @override
  String get socialInstagram => 'Instagram';

  @override
  String get socialFacebook => 'Facebook';

  @override
  String get socialTiktok => 'TikTok';

  @override
  String get socialWhatsapp => 'WhatsApp';

  @override
  String get socialYoutube => 'YouTube';

  @override
  String get socialLinkedin => 'LinkedIn';

  @override
  String get socialUrlLabel => 'URL du profil';

  @override
  String get socialInvalidUrl => 'Saisissez un lien http(s) valide.';

  @override
  String get trackOrderTitle => 'Suivre votre commande';

  @override
  String get trackOrderSubtitle =>
      'Saisissez votre numéro de commande et le téléphone utilisé lors du paiement.';

  @override
  String get orderNumberLabel => 'Numéro de commande';

  @override
  String get trackOrderAction => 'Suivre la commande';

  @override
  String get trackOrderRequired =>
      'Saisissez le numéro de commande et le téléphone.';

  @override
  String get trackOrderNotFound =>
      'Aucune commande ne correspond à ces informations. Vérifiez le numéro et le téléphone, puis réessayez.';

  @override
  String get trackOrderFailed =>
      'Impossible de retrouver la commande. Veuillez réessayer.';

  @override
  String get trackOrderItems => 'Articles';

  @override
  String get storefrontFollowUs => 'Suivez-nous';

  @override
  String get chatOnWhatsapp => 'Discuter sur WhatsApp';

  @override
  String get chatOnWhatsappMessage =>
      'Bonjour ! Je souhaite me renseigner sur ma commande.';

  @override
  String paginationRange(Object end, Object start, Object total) {
    return 'Affichage de $start-$end sur $total';
  }

  @override
  String paginationPageOf(Object page, Object total) {
    return 'Page $page sur $total';
  }

  @override
  String get paginationPrevious => 'Précédent';

  @override
  String get paginationNext => 'Suivant';

  @override
  String get backToTop => 'Retour en haut';

  @override
  String get hideSidebar => 'Masquer la barre latérale';

  @override
  String get showSidebar => 'Afficher la barre latérale';

  @override
  String get trackingTitle => 'Suivi de l\'expédition';

  @override
  String get trackingStageOrderReceived => 'Commande reçue';

  @override
  String get trackingStageProcessing => 'En préparation';

  @override
  String get trackingStageShipped => 'Expédiée';

  @override
  String get trackingStageInTransit => 'En transit';

  @override
  String get trackingStageOutForDelivery => 'En cours de livraison';

  @override
  String get trackingStageDelivered => 'Livrée';

  @override
  String get trackingNumberLabel => 'Numéro de suivi';

  @override
  String get shippingCompanyLabel => 'Transporteur';

  @override
  String get shipmentDateLabel => 'Date d\'expédition';

  @override
  String get estimatedDeliveryLabel => 'Livraison estimée';

  @override
  String get currentLocationLabel => 'Position actuelle';

  @override
  String get latestUpdateLabel => 'Dernière mise à jour';

  @override
  String get trackingUnavailable =>
      'Les informations de suivi ne sont pas encore disponibles.';

  @override
  String get trackingCancelled => 'Cette commande a été annulée.';

  @override
  String get openAction => 'Ouvrir';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get allTypes => 'Tous les types';

  @override
  String get categoriesLabel => 'Catégories';

  @override
  String fieldsCount(Object count) {
    return '$count champs';
  }

  @override
  String submissionsCountLabel(Object count) {
    return '$count soumissions';
  }

  @override
  String get formsPageTitle => 'Générateur de formulaires';

  @override
  String get formsPageSubtitle =>
      'Concevez des formulaires de contact, questionnaires et enquêtes.';

  @override
  String get createFormAction => 'Créer un formulaire';

  @override
  String get editFormTitle => 'Modifier le formulaire';

  @override
  String get formTitleLabel => 'Titre du formulaire';

  @override
  String get formSlugLabel => 'Slug URL (ex. contact-us)';

  @override
  String get formStatusLabel => 'Statut du formulaire';

  @override
  String get formDescriptionLabel => 'Description';

  @override
  String get formNameField => 'Nom complet';

  @override
  String get formEmailField => 'Adresse e-mail';

  @override
  String get formMessageField => 'Message / demande';

  @override
  String get formNamePlaceholder => 'Votre nom';

  @override
  String get formEmailPlaceholder => 'vous@entreprise.com';

  @override
  String get formMessagePlaceholder => 'Comment pouvons-nous vous aider ?';

  @override
  String get formTitleRequired => 'Le titre du formulaire est requis.';

  @override
  String get formUnpublishedHint =>
      'Publiez ce formulaire avant d\'envoyer un test.';

  @override
  String get selectOptionLabel => 'Sélectionnez une option';

  @override
  String get submitFormAction => 'Envoyer le formulaire';

  @override
  String get formSubmittedMessage => 'Formulaire envoyé avec succès.';

  @override
  String get formCreated => 'Formulaire créé.';

  @override
  String get formUpdated => 'Formulaire mis à jour.';

  @override
  String get formDeleted => 'Formulaire supprimé.';

  @override
  String get totalForms => 'Total des formulaires';

  @override
  String get activePublished => 'Actifs et publiés';

  @override
  String get totalSubmissions => 'Total des soumissions';

  @override
  String get searchFormsHint =>
      'Rechercher des formulaires par titre ou slug...';

  @override
  String get noFormsTitle => 'Aucun formulaire créé';

  @override
  String get noFormsMessage =>
      'Créez un nouveau formulaire pour recueillir des soumissions.';

  @override
  String get previewFormTooltip => 'Aperçu / tester le formulaire';

  @override
  String get colFields => 'Champs';

  @override
  String get directoryTitle => 'Annuaire d\'affaires';

  @override
  String get directorySubtitle =>
      'Organisez vos partenaires, fournisseurs et lieux avec leurs coordonnées.';

  @override
  String get addEntryAction => 'Ajouter une entrée';

  @override
  String get editEntryTitle => 'Modifier l\'entrée';

  @override
  String get entryNameLabel => 'Nom de l\'entreprise / entrée';

  @override
  String get entryNameHint => 'ex. Restaurant, Fournisseur';

  @override
  String get entryTypeLabel => 'Type';

  @override
  String get entryWebsiteLabel => 'URL du site web';

  @override
  String get entryContactLabel => 'Contact (téléphone / e-mail)';

  @override
  String get entryLocationLabel => 'Lieu / adresse';

  @override
  String get publishedInDirectory => 'Publié dans l\'annuaire';

  @override
  String get entryNameRequired => 'Le nom de l\'entrée est requis.';

  @override
  String get totalEntries => 'Total des entrées';

  @override
  String get withContactLabel => 'Avec contact';

  @override
  String get searchDirectoryHint =>
      'Rechercher par nom, catégorie ou contact...';

  @override
  String get noDirectoryTitle => 'Aucune entrée dans l\'annuaire';

  @override
  String get noDirectoryMessage =>
      'Ajoutez un partenaire, fournisseur ou lieu pour créer votre annuaire.';

  @override
  String get viewLinkTooltip => 'Voir le lien';

  @override
  String get websiteLabel => 'Site web';

  @override
  String get pagesPageTitle => 'Pages CMS';

  @override
  String get pagesPageSubtitle =>
      'Gérez les pages de politique, les conditions et le contenu du blog.';

  @override
  String get createPageAction => 'Créer une page';

  @override
  String get editPageTitle => 'Modifier la page';

  @override
  String get pageTitleLabel => 'Titre de la page';

  @override
  String get urlSlugLabel => 'Slug URL';

  @override
  String get shortExcerptLabel => 'Extrait court';

  @override
  String get excerptHint =>
      'Un résumé d\'une ou deux phrases affiché dans les listes...';

  @override
  String get coverImageUrlLabel => 'URL de l\'image de couverture';

  @override
  String get pageBodyLabel => 'Contenu de la page';

  @override
  String get pageBodyHint => 'Rédigez du texte, du Markdown ou un article...';

  @override
  String get seoMetaTitleLabel => 'Titre SEO';

  @override
  String get seoMetaDescriptionLabel => 'Description SEO';

  @override
  String get pageTitleRequired => 'Le titre de la page est requis.';

  @override
  String get pageContentRequired => 'Le contenu de la page est requis.';

  @override
  String get pageSlugRequired => 'Un slug URL valide est requis.';

  @override
  String pageSlugInUse(Object slug) {
    return 'Le slug \"/pages/$slug\" est déjà utilisé.';
  }

  @override
  String get totalPages => 'Total des pages';

  @override
  String get draftsLabel => 'Brouillons';

  @override
  String get searchPagesHint => 'Rechercher des pages par titre ou contenu...';

  @override
  String get noPagesTitle => 'Aucune page CMS';

  @override
  String get noPagesMessage =>
      'Créez une page pour publier du contenu sur votre vitrine.';

  @override
  String get readPreviewTooltip => 'Lire / prévisualiser la page';

  @override
  String get metaLabel => 'SEO';

  @override
  String get noContentYet => 'Aucun contenu ajouté.';

  @override
  String get colSeoTitle => 'Titre SEO';
}
