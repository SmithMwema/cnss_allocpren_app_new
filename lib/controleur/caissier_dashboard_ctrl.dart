// lib/controleur/caissier_dashboard_ctrl.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cnss_allocpren_app/modele/dossier.dart';
import 'package:cnss_allocpren_app/modele/notification.dart';
import 'package:cnss_allocpren_app/routes/app_pages.dart';
import 'package:cnss_allocpren_app/service/auth_service.dart';
import 'package:cnss_allocpren_app/service/firestore_service.dart';

class CaissierDashboardCtrl extends GetxController {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  // --- VARIABLES OBSERVABLES ---

  // NOUVEAU : Ajout de l'état de chargement
  var isLoading = true.obs;

  // RENOMMÉ : 'dossiersAPayer' est devenu 'listeDossiers' pour correspondre à la vue
  final RxList<Dossier> listeDossiers = <Dossier>[].obs;
  
  // Données de l'utilisateur pour l'affichage (ex: dans le menu)
  final RxString nomUtilisateur = ''.obs;
  // NOUVEAU : Ajout de l'email de l'utilisateur
  final RxString emailUtilisateur = ''.obs;


  @override
  void onInit() {
    super.onInit();
    // On récupère les informations de l'utilisateur connecté
    nomUtilisateur.value = _authService.user?.displayName ?? 'Caissier';
    emailUtilisateur.value = _authService.user?.email ?? 'Email non disponible';

    // On lie la liste des dossiers à payer au flux de données de Firestore
    listeDossiers.bindStream(
      _firestore.getDossiersParStatutStream('Validé par Directeur')
    );

    // On écoute le premier chargement de la liste pour masquer l'indicateur
    ever(listeDossiers, (_) {
      if (isLoading.value) {
        isLoading.value = false;
      }
    });
  }

  // NOUVEAU : Ajout de la méthode pour le rafraîchissement manuel
  /// Permet à la vue d'appeler cette fonction (ex: pull-to-refresh) sans causer d'erreur.
  Future<void> chargerDossiers() async {
    // Aucune action nécessaire car bindStream gère déjà les mises à jour en temps réel.
    // On peut ajouter un délai artificiel pour un effet visuel si désiré.
    // await Future.delayed(const Duration(seconds: 1));
  }

  /// Marque le dossier comme "Payé" et envoie une notification à la bénéficiaire.
  Future<void> payerDossier(Dossier dossier) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      await _firestore.updateDossierStatus(dossier.id!, "Payé");

      final notification = AppNotification(
        userId: dossier.userId,
        titre: 'Paiement effectué',
        message: 'Bonne nouvelle ! Le paiement de votre allocation a été effectué. Le processus est maintenant terminé.',
        dateCreation: DateTime.now(),
        dossierId: dossier.id!,
      );
      await _firestore.envoyerNotification(notification);

      Get.back(); // Ferme le dialogue
      Get.snackbar("Succès", "Le dossier a été marqué comme 'Payé'.", backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.back();
      Get.snackbar("Erreur", "La mise à jour a échoué : ${e.toString()}", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  
  /// Affiche une boîte de dialogue de confirmation avant de payer
  void confirmerPaiement(Dossier dossier) {
    Get.defaultDialog(
      title: "Confirmer le Paiement",
      middleText: "Voulez-vous marquer le dossier de ${dossier.nomAssure} comme 'Payé' ?",
      textConfirm: "Confirmer",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        Get.back(); // Ferme la confirmation
        payerDossier(dossier); // Lance le paiement
      },
      textCancel: "Annuler",
    );
  }
  
  /// Déconnecte l'utilisateur
  Future<void> seDeconnecter() async {
    await _authService.logout();
    Get.offAllNamed(AppPages.auth);
  }
}