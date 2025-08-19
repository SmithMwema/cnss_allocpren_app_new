// lib/controleur/listing_details_ctrl.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html;
import 'dart:convert';

import '../modele/dossier.dart';
import '../modele/listing.dart';
import '../service/pdf_export_service.dart';
import '../service/firestore_service.dart';

class ListingDetailsCtrl extends GetxController {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final PdfExportService _pdfExporter = PdfExportService();

  var isLoading = true.obs;
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
    if (listing.value == null || listing.value!.dossierIds.isEmpty) {
      isLoading.value = false;
      return;
    }
    try {
      // ON UTILISE LA NOUVELLE MÉTHODE EFFICACE
      final List<Dossier> dossiers = await _firestore.recupererDossiersParIds(listing.value!.dossierIds);
      dossiersDuListing.assignAll(dossiers);
    } catch (e) {
      print("ERREUR CHARGEMENT DETAILS LISTING: $e");
      Get.snackbar("Erreur", "Impossible de charger les détails des dossiers.");
    } finally {
      isLoading.value = false;
    }
  }

  void imprimerListing() async {
    if (listing.value != null && dossiersDuListing.isNotEmpty) {
      try {
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        await _pdfExporter.genererListingPdf(listing.value!, dossiersDuListing);
      } catch (e) {
        Get.snackbar("Erreur d'impression", "La génération du PDF a échoué : $e");
      } finally {
        if (Get.isDialogOpen ?? false) { Get.back(); }
      }
    } else {
      Get.snackbar("Erreur", "Les données du listing ne sont pas prêtes pour l'impression.");
    }
  }

  void exporterEnCsv() {
    if (listing.value == null || dossiersDuListing.isEmpty) {
      Get.snackbar("Erreur", "Aucune donnée à exporter.");
      return;
    }
    List<List<dynamic>> rows = [];
    rows.add(['N°', 'N° Sécu', 'Nom Complet de l\'Assurée']);
    for (var i = 0; i < dossiersDuListing.length; i++) {
      final dossier = dossiersDuListing[i];
      rows.add([i + 1, dossier.numSecuAssure, '${dossier.prenomAssure} ${dossier.nomAssure}']);
    }
    String csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", "listing_${listing.value!.id}.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
    Get.snackbar("Succès", "Le fichier CSV a été téléchargé.", backgroundColor: Colors.green, colorText: Colors.white);
  }
}