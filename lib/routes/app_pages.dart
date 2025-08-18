// lib/routes/app_pages.dart

import 'package:get/get.dart';

// --- IMPORTS DES CONTRÔLEURS ---
import 'package:cnss_allocpren_app/controleur/auth_ctrl.dart';
import 'package:cnss_allocpren_app/controleur/declaration_ctrl.dart';
import 'package:cnss_allocpren_app/controleur/accueil_ctrl.dart';
import 'package:cnss_allocpren_app/controleur/notification_ctrl.dart';
import 'package:cnss_allocpren_app/controleur/admin_add_user_ctrl.dart';
import 'package:cnss_allocpren_app/controleur/agent_details_dossier_ctrl.dart';
// NOUVEL IMPORT AJOUTÉ
import 'package:cnss_allocpren_app/controleur/agent_dashboard_ctrl.dart'; 


// --- IMPORTS DES VUES ---
import '../vue/accueil_vue.dart';
import '../vue/agent/agent_dashboard_vue.dart';
import '../vue/auth_vue.dart';
import '../vue/declaration_vue.dart';
import '../vue/directeur/directeur_dashboard_vue.dart';
import '../vue/lancement_moderne_vue.dart';
import '../vue/caissier/caissier_dashboard_vue.dart';
import '../vue/admin/admin_dashboard_vue.dart';
import '../vue/agent/agent_details_dossier_vue.dart';
import '../vue/admin/admin_add_user_vue.dart';
import '../vue/notification_vue.dart';

/// Classe centrale pour la gestion des routes de l'application.
class AppPages {
  // --- NOMS DES ROUTES (CONSTANTES) ---
  static const String lancement = '/lancement';
  static const String auth = '/auth';
  static const String accueil = '/accueil';
  static const String agentDashboard = '/agent-dashboard';
  static const String agentDetailsDossier = '/agent-details-dossier';
  static const String directeurDashboard = '/directeur-dashboard';
  static const String caissierDashboard = '/caissier-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminAddUser = '/admin-add-user';
  static const String declaration = '/declaration';
  static const String notifications = '/notifications';

  // --- LISTE DES PAGES (ROUTES) ---
  static final List<GetPage> routes = [
    GetPage(name: lancement, page: () => const LancementModerneVue()),
    
    GetPage(
      name: auth, 
      page: () => const AuthVue(),
      binding: BindingsBuilder(() { Get.lazyPut<AuthCtrl>(() => AuthCtrl()); }),
    ),
    
    GetPage(
      name: accueil, 
      page: () => const AccueilVue(),
      binding: BindingsBuilder(() { Get.lazyPut<AccueilCtrl>(() => AccueilCtrl()); }),
    ),
    
    // --- CORRECTION APPLIQUÉE ICI ---
    // On ajoute le 'binding' pour initialiser le contrôleur de l'agent.
    GetPage(
      name: agentDashboard, 
      page: () => const AgentDashboardVue(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AgentDashboardCtrl>(() => AgentDashboardCtrl());
      }),
    ),
    
    GetPage(
      name: agentDetailsDossier,
      page: () => const AgentDetailsDossierVue(),
      binding: BindingsBuilder(() { Get.lazyPut<AgentDetailsDossierCtrl>(() => AgentDetailsDossierCtrl()); }),
    ),

    GetPage(name: directeurDashboard, page: () => const DirecteurDashboardVue()),
    GetPage(name: caissierDashboard, page: () => const CaissierDashboardVue()),
    GetPage(name: adminDashboard, page: () => const AdminDashboardVue()),
    
    GetPage(
      name: notifications,
      page: () => const NotificationVue(),
      binding: BindingsBuilder(() { Get.lazyPut<NotificationCtrl>(() => NotificationCtrl()); }),
    ),
    
    GetPage(
      name: adminAddUser,
      page: () => const AdminAddUserVue(),
      binding: BindingsBuilder(() { Get.lazyPut<AdminAddUserCtrl>(() => AdminAddUserCtrl()); }),
    ),

    GetPage(
      name: declaration,
      page: () => const DeclarationVue(),
      binding: BindingsBuilder(() { Get.lazyPut<DeclarationCtrl>(() => DeclarationCtrl()); }),
    ),
  ];
}