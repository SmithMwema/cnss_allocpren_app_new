// lib/routes/app_pages.dart

import 'package:get/get.dart';

// --- CONTRÔLEURS ---
import '../controleur/accueil_ctrl.dart';
import '../controleur/admin_add_user_ctrl.dart';
import '../controleur/agent_dashboard_ctrl.dart';
import '../controleur/agent_details_dossier_ctrl.dart';
import '../controleur/auth_ctrl.dart';
import '../controleur/beneficiaire_details_dossier_ctrl.dart';
import '../controleur/caissier_dashboard_ctrl.dart';
import '../controleur/caissier_listing_details_ctrl.dart';
import '../controleur/declaration_ctrl.dart';
import '../controleur/listing_details_ctrl.dart';
import '../controleur/notification_ctrl.dart';

// --- VUES ---
import '../vue/accueil_vue.dart';
import '../vue/auth_vue.dart';
import '../vue/declaration_vue.dart';
import '../vue/lancement_moderne_vue.dart';
import '../vue/notification_vue.dart';
// Vues > Admin
import '../vue/admin/admin_add_user_vue.dart';
import '../vue/admin/admin_dashboard_vue.dart';
// Vues > Agent
import '../vue/agent/agent_dashboard_vue.dart';
import '../vue/agent/agent_details_dossier_vue.dart';
import '../vue/agent/listing_details_vue.dart';
// Vues > Bénéficiaire
import '../vue/beneficiaire/beneficiaire_details_dossier_vue.dart';
// Vues > Caissier
import '../vue/caissier/caissier_dashboard_vue.dart';
import '../vue/caissier/caissier_listing_details_vue.dart';
// Vues > Directeur
import '../vue/directeur/directeur_dashboard_vue.dart';


class AppPages {
  // --- NOMS DES ROUTES (CONSTANTES) ---
  static const String lancement = '/lancement';
  static const String auth = '/auth';
  
  // Routes Bénéficiaire
  static const String accueil = '/accueil';
  static const String declaration = '/declaration';
  static const String notifications = '/notifications';
  static const String beneficiaireDetailsDossier = '/beneficiaire-details-dossier';
  
  // Routes Personnel
  static const String agentDashboard = '/agent-dashboard';
  static const String agentDetailsDossier = '/agent-details-dossier';
  static const String listingDetails = '/listing-details'; // Pour l'agent
  static const String directeurDashboard = '/directeur-dashboard';
  static const String caissierDashboard = '/caissier-dashboard';
  // --- CONSTANTE MANQUANTE AJOUTÉE ICI ---
  static const String caissierListingDetails = '/caissier-listing-details';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminAddUser = '/admin-add-user';

  // --- LISTE DES PAGES (ROUTES) ---
  static final List<GetPage> routes = [
    GetPage(name: lancement, page: () => const LancementModerneVue()),
    GetPage(name: auth, page: () => const AuthVue(), binding: BindingsBuilder(() => Get.lazyPut<AuthCtrl>(() => AuthCtrl()))),
    
    // Bénéficiaire
    GetPage(name: accueil, page: () => const AccueilVue(), binding: BindingsBuilder(() => Get.lazyPut<AccueilCtrl>(() => AccueilCtrl()))),
    GetPage(name: declaration, page: () => const DeclarationVue(), binding: BindingsBuilder(() => Get.lazyPut<DeclarationCtrl>(() => DeclarationCtrl()))),
    GetPage(name: notifications, page: () => const NotificationVue(), binding: BindingsBuilder(() => Get.lazyPut<NotificationCtrl>(() => NotificationCtrl()))),
    GetPage(name: beneficiaireDetailsDossier, page: () => const BeneficiaireDetailsDossierVue(), binding: BindingsBuilder(() => Get.lazyPut<BeneficiaireDetailsDossierCtrl>(() => BeneficiaireDetailsDossierCtrl()))),

    // Personnel
    GetPage(name: agentDashboard, page: () => const AgentDashboardVue(), binding: BindingsBuilder(() => Get.lazyPut<AgentDashboardCtrl>(() => AgentDashboardCtrl()))),
    GetPage(name: agentDetailsDossier, page: () => const AgentDetailsDossierVue(), binding: BindingsBuilder(() => Get.lazyPut<AgentDetailsDossierCtrl>(() => AgentDetailsDossierCtrl()))),
    GetPage(name: listingDetails, page: () => const ListingDetailsVue(), binding: BindingsBuilder(() => Get.lazyPut<ListingDetailsCtrl>(() => ListingDetailsCtrl()))),

    GetPage(name: directeurDashboard, page: () => const DirecteurDashboardVue()),
    
    GetPage(name: caissierDashboard, page: () => const CaissierDashboardVue(), binding: BindingsBuilder(() => Get.lazyPut<CaissierDashboardCtrl>(() => CaissierDashboardCtrl()))),
    GetPage(
      name: caissierListingDetails, 
      page: () => const CaissierListingDetailsVue(), 
      binding: BindingsBuilder(() => Get.lazyPut<CaissierListingDetailsCtrl>(() => CaissierListingDetailsCtrl()))
    ),

    GetPage(name: adminDashboard, page: () => const AdminDashboardVue()),
    GetPage(name: adminAddUser, page: () => const AdminAddUserVue(), binding: BindingsBuilder(() => Get.lazyPut<AdminAddUserCtrl>(() => AdminAddUserCtrl()))),
  ];
}