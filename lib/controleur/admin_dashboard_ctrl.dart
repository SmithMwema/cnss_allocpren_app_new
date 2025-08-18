import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modele/utilisateur.dart';
import '../routes/app_pages.dart';
import '../service/auth_service.dart';
import '../service/firestore_service.dart';

// Classe utilitaire pour les données du graphique
class UserParRole {
  final String role;
  final int nombre;
  final Color couleur;
  UserParRole(this.role, this.nombre, this.couleur);
}

class AdminDashboardCtrl extends GetxController {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  var selectedIndex = 0.obs;
  void changePage(int index) {
    selectedIndex.value = index;
    if (index == 0 || index == 1) {
      chargerToutesLesDonnees();
    }
  }

  var isLoading = true.obs;
  
  // Pour l'onglet "Statistiques"
  var totalUtilisateurs = 0.obs;
  var totalBeneficiaires = 0.obs;
  final RxList<UserParRole> userStatsData = <UserParRole>[].obs;
  
  // Pour l'onglet "Utilisateurs"
  final RxList<Utilisateur> listeUtilisateurs = <Utilisateur>[].obs;
  
  // --- VARIABLES RAJOUTÉES POUR LE SIDEBAR ---
  var nomUtilisateur = ''.obs;
  var emailUtilisateur = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _chargerInfosUtilisateur(); // On charge les infos au démarrage
    chargerToutesLesDonnees();
  }

  // --- MÉTHODE RAJOUTÉE POUR LE SIDEBAR ---
  void _chargerInfosUtilisateur() {
    if (_authService.user != null) {
      nomUtilisateur.value = _authService.user!.displayName ?? 'Admin Système';
      emailUtilisateur.value = _authService.user!.email ?? 'admin@inconnu.com';
    }
  }

  Future<void> chargerToutesLesDonnees() async {
    try {
      isLoading.value = true;
      final tousLesUtilisateurs = await _firestore.recupererTousLesUtilisateurs();
      listeUtilisateurs.assignAll(tousLesUtilisateurs);
      _calculerKpisUtilisateurs(tousLesUtilisateurs);
      _creerDonneesGraphiqueUtilisateurs(tousLesUtilisateurs);
    } finally {
      isLoading.value = false;
    }
  }

  void _calculerKpisUtilisateurs(List<Utilisateur> utilisateurs) {
    totalUtilisateurs.value = utilisateurs.length;
    totalBeneficiaires.value = utilisateurs.where((u) => u.role == 'beneficiaire').length;
  }
  
  void _creerDonneesGraphiqueUtilisateurs(List<Utilisateur> utilisateurs) {
    final data = [
      UserParRole('Agents', utilisateurs.where((u) => u.role == 'agent').length, Colors.purple),
      UserParRole('Directeurs', utilisateurs.where((u) => u.role == 'directeur').length, Colors.orange),
      UserParRole('Caissiers', utilisateurs.where((u) => u.role == 'caissier').length, Colors.green),
      UserParRole('Admins', utilisateurs.where((u) => u.role == 'admin').length, Colors.blue),
    ];
    userStatsData.assignAll(data.where((d) => d.nombre > 0).toList());
  }
  
  Future<void> seDeconnecter() async {
    await _authService.logout();
    Get.offAllNamed(AppPages.auth);
  }
}