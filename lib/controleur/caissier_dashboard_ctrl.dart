// lib/controleur/caissier_dashboard_ctrl.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modele/dossier.dart';
import '../modele/notification.dart';
import '../routes/app_pages.dart';
import '../service/auth_service.dart';
import '../service/firestore_service.dart';

class CaissierDashboardCtrl extends GetxController {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = true.obs;
  // NOUVEAU : Pour gérer les onglets
  var selectedIndex = 0.obs; 

  // NOUVEAU : Deux listes distinctes
  final RxList<Dossier> dossiersAPayer = <Dossier>[].obs;
  final RxList<Dossier> historiquePaiements = <Dossier>[].obs;
  
  final RxString nomUtilisateur = ''.obs;
  final RxString emailUtilisateur = ''.obs;

  @override
  void onInit() {
    super.onInit();
    nomUtilisateur.value = _authService.user?.displayName ?? 'Caissier';
    emailUtilisateur.value = _authService.user?.email ?? 'Email non disponible';

    // On lie chaque liste à son propre flux de données
    dossiersAPayer.bindStream(
      _firestore.getDossiersParStatutStream('Prêt pour paiement')
    );
    historiquePaiements.bindStream(
      _firestore.getDossiersParStatutStream('Payé')
    );

    // On arrête le chargement dès que la première liste (la plus importante) est prête
    ever(dossiersAPayer, (_) {
      if (isLoading.value) {
        isLoading.value = false;
      }
    });
  }
  
  // NOUVEAU : Pour changer d'onglet
  void changePage(int index) {
    selectedIndex.value = index;
  }

  Future<void> chargerDonnees() async {
    // Laissé vide car le stream gère le rafraîchissement
  }

  Future<void> payerDossier(Dossier dossier) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      await _firestore.updateDossierStatus(dossier.id!, "Payé");

      final notification = AppNotification(
        userId: dossier.userId,
        titre: 'Paiement effectué',
        message: 'Bonne nouvelle ! Le paiement de votre allocation a été effectué.',
        dateCreation: DateTime.now(),
        dossierId: dossier.id!,
      );
      await _firestore.envoyerNotification(notification);

      Get.back(); // Ferme le spinner
      Get.snackbar("Succès", "Le dossier a été marqué comme 'Payé'.", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.back(); // Ferme le spinner
      Get.snackbar("Erreur", "La mise à jour a échoué : ${e.toString()}", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  
  void confirmerPaiement(Dossier dossier) {
    Get.defaultDialog(
      title: "Confirmer le Paiement",
      middleText: "Voulez-vous marquer le dossier de ${dossier.prenomAssure} ${dossier.nomAssure} comme 'Payé' ?",
      textConfirm: "Confirmer",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        Get.back();
        payerDossier(dossier);
      },
      textCancel: "Annuler",
    );
  }
  
  Future<void> seDeconnecter() async {
    await _authService.logout();
    Get.offAllNamed(AppPages.auth);
  }
}