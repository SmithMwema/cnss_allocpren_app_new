// lib/controleur/caissier_listing_details_ctrl.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modele/dossier.dart';
import '../modele/listing.dart';
import '../service/firestore_service.dart';

class CaissierListingDetailsCtrl extends GetxController {
  final FirestoreService _firestore = Get.find<FirestoreService>();

  var isLoading = true.obs;
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

  Future<void> _chargerDossiers() async {
    isLoading.value = true;
    if (listing.value == null || listing.value!.dossiers.isEmpty) {
      isLoading.value = false;
      return;
    }
    try {
      final List<String> ids = listing.value!.dossiers.map((d) => d.dossierId).toList();
      final List<Dossier> dossiers = await _firestore.recupererDossiersParIds(ids);
      
      for (var dossier in dossiers) {
        final paiementInfo = listing.value!.dossiers.firstWhere(
          (p) => p.dossierId == dossier.id,
          orElse: () => DossierPaiement(dossierId: dossier.id!)
        );
        if (paiementInfo.statutPaiement == 'Payé') {
          dossier.statut = 'Payé'; 
        } else {
          dossier.statut = 'Prêt pour paiement';
        }
      }
      
      dossiersDuListing.assignAll(dossiers);

    } catch (e) {
      print("ERREUR _chargerDossiers Caissier: $e");
      Get.snackbar("Erreur", "Impossible de charger les détails des dossiers.");
    } finally {
      isLoading.value = false;
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
        _executerPaiement(dossier);
      },
      textCancel: "Annuler",
    );
  }

  Future<void> _executerPaiement(Dossier dossier) async {
    processingPaymentId.value = dossier.id!;
    try {
      final success = await _firestore.payerDossierDansListing(
        listingId: listing.value!.id!,
        dossierPaye: dossier,
      );

      if (success) {
        int index = dossiersDuListing.indexWhere((d) => d.id == dossier.id);
        if (index != -1) {
          dossiersDuListing[index].statut = "Payé";
          dossiersDuListing.refresh();
        }

        int listingIndex = listing.value!.dossiers.indexWhere((d) => d.dossierId == dossier.id);
        if(listingIndex != -1) {
          listing.value!.dossiers[listingIndex].statutPaiement = "Payé";
        }
        
        Get.snackbar("Succès", "Le dossier a été marqué comme 'Payé'.", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        throw Exception("La transaction de paiement a échoué.");
      }
      
    } catch (e) {
      Get.snackbar("Erreur", "La mise à jour a échoué. Veuillez réessayer.", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      processingPaymentId.value = '';
    }
  }
}