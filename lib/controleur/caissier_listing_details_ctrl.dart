// lib/controleur/caissier_listing_details_ctrl.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modele/dossier.dart';
import '../modele/listing.dart';
import '../modele/notification.dart';
import '../service/firestore_service.dart';

class CaissierListingDetailsCtrl extends GetxController {
  final FirestoreService _firestore = Get.find<FirestoreService>();

  var isLoading = true.obs;
  // NOUVEAU : Pour afficher un spinner sur une seule ligne à la fois
  var processingPaymentId = ''.obs;

  final Rx<Listing?> listing = Rx<Listing?>(null);
  final RxList<Dossier> dossiersDuListing = <Dossier>[].obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic argument = Get.arguments;

    if (argument is Listing) {
      listing.value = argument;
      _chargerDossiers();
    } else {
      isLoading.value = false;
      Get.snackbar("Erreur", "Impossible de récupérer les informations du listing.");
    }
  }

  /// Charge les détails de tous les dossiers contenus dans le listing.
  Future<void> _chargerDossiers() async {
    isLoading.value = true;
    if (listing.value == null || listing.value!.dossierIds.isEmpty) {
      isLoading.value = false;
      return;
    }
    try {
      final List<Dossier> dossiers = await _firestore.recupererDossiersParIds(listing.value!.dossierIds);
      dossiersDuListing.assignAll(dossiers);
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de charger les détails des dossiers.");
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Affiche la boîte de dialogue de confirmation avant le paiement.
  void confirmerPaiement(Dossier dossier) {
    Get.defaultDialog(
      title: "Confirmer le Paiement",
      middleText: "Voulez-vous marquer le dossier de ${dossier.prenomAssure} ${dossier.nomAssure} comme 'Payé' ?",
      textConfirm: "Confirmer",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        Get.back(); // Ferme la confirmation
        _executerPaiement(dossier); // Lance le paiement
      },
      textCancel: "Annuler",
    );
  }

  /// Met à jour le statut du dossier et envoie une notification.
  Future<void> _executerPaiement(Dossier dossier) async {
    processingPaymentId.value = dossier.id!; // Affiche le spinner sur la ligne
    try {
      // Étape 1 : Mettre à jour le statut du dossier principal
      await _firestore.updateDossierStatus(dossier.id!, "Payé");

      // Étape 2 : Envoyer une notification à la bénéficiaire
      final notification = AppNotification(
        userId: dossier.userId,
        titre: 'Paiement effectué',
        message: 'Bonne nouvelle ! Le paiement de votre allocation a été effectué. Le processus est maintenant terminé.',
        dateCreation: DateTime.now(),
        dossierId: dossier.id!,
      );
      await _firestore.envoyerNotification(notification);
      
      // Étape 3 : Mettre à jour l'objet localement pour que la vue réagisse instantanément
      int index = dossiersDuListing.indexWhere((d) => d.id == dossier.id);
      if (index != -1) {
        dossiersDuListing[index].statut = "Payé";
        dossiersDuListing.refresh(); // Force la mise à jour de la vue
      }

      Get.snackbar("Succès", "Le dossier a été marqué comme 'Payé'.", backgroundColor: Colors.green, colorText: Colors.white);
      
    } catch (e) {
      Get.snackbar("Erreur", "La mise à jour a échoué : ${e.toString()}", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      processingPaymentId.value = ''; // Cache le spinner
    }
  }
}