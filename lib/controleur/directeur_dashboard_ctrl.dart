// lib/controleur/directeur_dashboard_ctrl.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cnss_allocpren_app/modele/dossier.dart';
import 'package:cnss_allocpren_app/modele/notification.dart';
import 'package:cnss_allocpren_app/routes/app_pages.dart';
import 'package:cnss_allocpren_app/service/auth_service.dart';
import 'package:cnss_allocpren_app/service/firestore_service.dart';

class DirecteurDashboardCtrl extends GetxController with GetSingleTickerProviderStateMixin {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  late TabController tabController;

  // --- NOUVELLE VARIABLE AJOUTÉE ---
  /// Gère l'affichage de l'indicateur de chargement initial.
  var isLoading = true.obs;

  // --- Listes Réactives ---
  final RxList<Dossier> tousLesDossiers = <Dossier>[].obs;
  final RxList<Dossier> dossiersAValider = <Dossier>[].obs;

  // --- KPIs Réactifs ---
  final RxInt totalDossiers = 0.obs;
  final RxInt dossiersPayes = 0.obs;
  final RxInt dossiersEnAttente = 0.obs;
  final RxInt dossiersRejetes = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    
    // --- LIAISON DES STREAMS ---
    tousLesDossiers.bindStream(_firestore.getDossiersStream());
    dossiersAValider.bindStream(
      _firestore.getDossiersParStatutStream('Traité par Agent')
    );

    // On recalculera les KPIs chaque fois que la liste complète change
    ever(tousLesDossiers, _calculerKpis);

    // On arrête l'indicateur de chargement dès que les premières données sont arrivées.
    ever(dossiersAValider, (_) {
      if (isLoading.value) {
        isLoading.value = false;
      }
    });
  }
  
  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
  
  // --- NOUVELLE MÉTHODE AJOUTÉE ---
  /// Méthode pour le rafraîchissement manuel (ex: pull-to-refresh).
  /// Dans notre cas avec bindStream, ce n'est pas strictement nécessaire
  /// car les données sont live, mais c'est une bonne pratique de l'avoir
  /// pour que la vue ne génère pas d'erreur.
  Future<void> chargerDonnees() async {
    // On peut simuler un petit délai pour un effet visuel si on le souhaite
    // await Future.delayed(const Duration(seconds: 1));
    // Les streams sont déjà en écoute, donc il n'y a rien de plus à faire.
  }

  void _calculerKpis(List<Dossier> dossiers) {
    totalDossiers.value = dossiers.length;
    dossiersPayes.value = dossiers.where((d) => d.statut == 'Payé').length;
    dossiersRejetes.value = dossiers.where((d) => d.statut == 'Rejeté').length;
    dossiersEnAttente.value = totalDossiers.value - dossiersPayes.value - dossiersRejetes.value;
  }
  
  Future<void> _updateStatusAndNotify({
    required Dossier dossier,
    required String nouveauStatut,
    String? motif,
    required String successMessage,
    required String notificationMessage,
  }) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    
    try {
      await _firestore.updateDossierStatus(dossier.id!, nouveauStatut, motif: motif);
      
      final notification = AppNotification(
        userId: dossier.userId,
        titre: 'Mise à jour de votre dossier',
        message: notificationMessage,
        dateCreation: DateTime.now(), 
        dossierId: dossier.id!,
      );
      await _firestore.envoyerNotification(notification);

      Get.back();
      Get.snackbar('Succès', successMessage, backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.back();
      Get.snackbar('Erreur', 'La mise à jour a échoué : ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void validerDossier(Dossier dossier) {
    _updateStatusAndNotify(
      dossier: dossier,
      nouveauStatut: 'Validé par Directeur',
      successMessage: 'Dossier validé et transféré au caissier.',
      notificationMessage: 'Excellente nouvelle ! Votre dossier a été validé par le directeur et est prêt pour le paiement.',
    );
  }
  
  void rejeterDossier(Dossier dossier, String motif) {
    _updateStatusAndNotify(
      dossier: dossier,
      nouveauStatut: 'Rejeté',
      motif: motif,
      successMessage: 'Le dossier a été rejeté.',
      notificationMessage: 'Votre dossier a été rejeté par le directeur pour le motif suivant : "$motif".',
    );
  }

  Future<void> seDeconnecter() async {
    await _authService.logout();
    Get.offAllNamed(AppPages.auth);
  }
  
  Color getColorForStatus(String statut) {
    switch (statut) {
      case 'Soumis': return Colors.blue;
      case 'Traité par Agent': return Colors.purple;
      case 'Validé par Directeur': return Colors.orange;
      case 'Payé': return Colors.green;
      case 'Rejeté': return Colors.red;
      default: return Colors.grey;
    }
  }
}