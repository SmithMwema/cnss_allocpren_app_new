// lib/controleur/agent_dashboard_ctrl.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modele/dossier.dart';
import '../modele/listing.dart';
import '../routes/app_pages.dart';
import '../service/auth_service.dart';
import '../service/firestore_service.dart';

class AgentDashboardCtrl extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  var selectedIndex = 0.obs;
  var isLoading = true.obs;
  final RxString emailUtilisateur = ''.obs;

  final dossiersATraiter = <Dossier>[].obs;
  final dossiersPourListing = <Dossier>[].obs;
  final dossiersSuivi = <Dossier>[].obs;
  final historiqueListings = <Listing>[].obs;

  var isSearching = false.obs;
  var searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  var isProcessingListing = false.obs;
  final RxList<Dossier> selectedForListing = <Dossier>[].obs;

  bool isSelected(Dossier dossier) => selectedForListing.contains(dossier);

  List<dynamic> get listeFiltreeAffichee {
    if (selectedIndex.value == 3) {
      if(searchQuery.isEmpty) return historiqueListings;
      return historiqueListings.where((l) => l.id!.contains(searchQuery.value)).toList();
    }
    List<Dossier> sourceList;
    switch (selectedIndex.value) {
      case 0: sourceList = dossiersATraiter; break;
      case 1: sourceList = dossiersPourListing; break;
      case 2: sourceList = dossiersSuivi; break;
      default: sourceList = [];
    }
    if (searchQuery.isEmpty) return sourceList;
    return sourceList.where((dossier) {
      final nomComplet = "${dossier.prenomAssure} ${dossier.nomAssure}".toLowerCase();
      final numSecu = dossier.numSecuAssure.toLowerCase();
      final query = searchQuery.value.toLowerCase();
      return nomComplet.contains(query) || numSecu.contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    emailUtilisateur.value = _authService.user?.email ?? 'Email non disponible';
    
    dossiersATraiter.bindStream(_firestoreService.getDossiersParStatutStream('Soumis'));
    dossiersPourListing.bindStream(_firestoreService.getDossiersParStatutStream('Validé par Directeur'));
    dossiersSuivi.bindStream(_firestoreService.getDossiersStreamParStatuts(['Traité par Agent', 'Prêt pour paiement', 'Payé', 'Rejeté']));
    historiqueListings.bindStream(_firestoreService.getListingsStream());

    ever(dossiersATraiter, (_) => isLoading.value = false);

    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void changePage(int index) {
    selectedIndex.value = index;
    if (isSearching.value) stopSearch();
    if (index != 1) {
      selectedForListing.clear();
    }
  }
  
  void toggleSelection(Dossier dossier) {
    if (isSelected(dossier)) {
      selectedForListing.remove(dossier);
    } else {
      selectedForListing.add(dossier);
    }
  }

  // --- MÉTHODE CORRIGÉE ---
  void genererListing() async {
    if (selectedForListing.isEmpty) { Get.snackbar("Aucune sélection", "Veuillez cocher au moins un dossier."); return; }
    Get.defaultDialog(
      title: "Confirmation",
      middleText: "Voulez-vous vraiment générer un listing et notifier ${selectedForListing.length} bénéficiaires ?",
      textConfirm: "Oui, Générer", textCancel: "Annuler", confirmTextColor: Colors.white, buttonColor: Colors.green.shade700,
      onConfirm: () async {
        Get.back();
        isProcessingListing.value = true;
        
        final String agentId = _authService.user!.uid;

        // On crée la liste d'objets DossierPaiement selon la nouvelle structure
        final List<DossierPaiement> dossiersPourLeListing = selectedForListing
            .where((d) => d.id != null)
            .map((d) => DossierPaiement(dossierId: d.id!))
            .toList();

        final nouveauListing = Listing(
          dateCreation: DateTime.now(),
          creeParId: agentId,
          dossiers: dossiersPourLeListing, // On passe la nouvelle liste structurée
        );

        final bool success = await _firestoreService.creerListingNotifierEtMajDossiers(
          listing: nouveauListing,
          dossiers: selectedForListing,
          nouveauStatutDossier: "Prêt pour paiement",
        );

        isProcessingListing.value = false;
        if (success) {
          Get.snackbar("Succès", "Le listing a été créé et les notifications envoyées.", backgroundColor: Colors.green, colorText: Colors.white);
          selectedForListing.clear();
        } else {
          Get.snackbar("Erreur", "La création du listing a échoué. Veuillez réessayer.", backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    );
  }

  void voirDetailsDossier(Dossier dossier) { 
    Get.toNamed(AppPages.agentDetailsDossier, arguments: dossier); 
  }

  void voirDetailsListing(Listing listing) {
    Get.toNamed(AppPages.listingDetails, arguments: listing);
  }

  Future<void> seDeconnecter() async { 
    await _authService.logout(); 
    Get.offAllNamed(AppPages.auth); 
  }
  
  void startSearch() { isSearching.value = true; }
  void stopSearch() { isSearching.value = false; searchController.clear(); }
}