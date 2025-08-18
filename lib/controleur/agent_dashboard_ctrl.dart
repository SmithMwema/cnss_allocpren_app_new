// lib/controleur/agent_dashboard_ctrl.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modele/dossier.dart';
import '../service/auth_service.dart';
import '../service/firestore_service.dart';

class AgentDashboardCtrl extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  var selectedIndex = 0.obs;
  var dossiersATraiter = <Dossier>[].obs;
  var dossiersTraites = <Dossier>[].obs;
  var isLoading = true.obs;
  final RxString emailUtilisateur = ''.obs;

  // --- AJOUTS POUR LA RECHERCHE ---
  var isSearching = false.obs;
  var searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // --- Listes filtrées pour l'affichage ---
  List<Dossier> get filteredDossiersATraiter {
    if (searchQuery.isEmpty) {
      return dossiersATraiter;
    }
    return dossiersATraiter.where((dossier) {
      final nomComplet = "${dossier.prenomAssure} ${dossier.nomAssure}".toLowerCase();
      return nomComplet.contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  List<Dossier> get filteredDossiersTraites {
    if (searchQuery.isEmpty) {
      return dossiersTraites;
    }
    return dossiersTraites.where((dossier) {
      final nomComplet = "${dossier.prenomAssure} ${dossier.nomAssure}".toLowerCase();
      return nomComplet.contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    emailUtilisateur.value = _authService.user?.email ?? 'Email non disponible';
    _chargerStreamsDossiers();
    // Écoute les changements dans le champ de recherche
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose(); // Ne pas oublier de nettoyer !
    super.onClose();
  }

  void _chargerStreamsDossiers() {
    isLoading.value = true;
    dossiersATraiter.bindStream(_firestoreService.getDossiersParStatutStream('Soumis'));
    dossiersTraites.bindStream(_firestoreService.getDossiersStreamParStatuts(['Traité par Agent', 'Rejeté']));
    ever(dossiersATraiter, (_) => isLoading.value = false);
  }

  void changePage(int index) {
    selectedIndex.value = index;
  }

  void voirDetailsDossier(Dossier dossier) {
    Get.toNamed('/agent-details-dossier', arguments: dossier);
  }

  Future<void> seDeconnecter() async {
    await _authService.logout();
    Get.offAllNamed('/auth');
  }

  // --- NOUVELLES MÉTHODES POUR LA RECHERCHE ---
  void startSearch() {
    isSearching.value = true;
  }

  void stopSearch() {
    isSearching.value = false;
    searchController.clear();
  }
}