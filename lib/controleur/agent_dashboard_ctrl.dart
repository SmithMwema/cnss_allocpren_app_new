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
  var isLoading = true.obs;
  final RxString emailUtilisateur = ''.obs;

  // --- VARIABLES ET LOGIQUE POUR LA RECHERCHE ---
  var isSearching = false.obs;
  var searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // Listes originales contenant toutes les données de Firestore
  final _dossiersATraiterSource = <Dossier>[].obs;
  final _dossiersTraitesSource = <Dossier>[].obs;

  // Getters pour les listes filtrées (celles affichées à l'écran)
  List<Dossier> get filteredDossiersATraiter {
    if (searchQuery.isEmpty) {
      return _dossiersATraiterSource;
    }
    return _dossiersATraiterSource.where((dossier) {
      final nomComplet = "${dossier.prenomAssure} ${dossier.nomAssure}".toLowerCase();
      final numSecu = dossier.numSecuAssure.toLowerCase();
      final query = searchQuery.value.toLowerCase();
      return nomComplet.contains(query) || numSecu.contains(query);
    }).toList();
  }

  List<Dossier> get filteredDossiersTraites {
    if (searchQuery.isEmpty) {
      return _dossiersTraitesSource;
    }
    return _dossiersTraitesSource.where((dossier) {
      final nomComplet = "${dossier.prenomAssure} ${dossier.nomAssure}".toLowerCase();
      final numSecu = dossier.numSecuAssure.toLowerCase();
      final query = searchQuery.value.toLowerCase();
      return nomComplet.contains(query) || numSecu.contains(query);
    }).toList();
  }
  // --- FIN DE LA LOGIQUE DE RECHERCHE ---

  @override
  void onInit() {
    super.onInit();
    emailUtilisateur.value = _authService.user?.email ?? 'Email non disponible';
    
    // On lie les streams aux listes sources
    _dossiersATraiterSource.bindStream(_firestoreService.getDossiersParStatutStream('Soumis'));
    _dossiersTraitesSource.bindStream(_firestoreService.getDossiersStreamParStatuts(['Traité par Agent', 'Rejeté']));

    ever(_dossiersATraiterSource, (_) => isLoading.value = false);

    // Écoute les changements dans le champ de recherche pour mettre à jour la requête
    searchController.addListener(() {
      // On met à jour notre variable réactive searchQuery à chaque changement
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose(); // Important pour la gestion de la mémoire
    super.onClose();
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

  // --- MÉTHODES COMPLÈTES POUR GÉRER L'ÉTAT DE LA RECHERCHE ---
  void startSearch() {
    isSearching.value = true;
  }

  void stopSearch() {
    isSearching.value = false;
    searchController.clear(); // Efface le texte et déclenche la mise à jour
  }
}