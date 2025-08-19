// lib/controleur/beneficiaire_details_dossier_ctrl.dart

import 'package:get/get.dart';
import '../modele/dossier.dart';

class BeneficiaireDetailsDossierCtrl extends GetxController {
  // Variable réactive pour stocker le dossier à afficher.
  // On l'initialise à null.
  final Rx<Dossier?> dossier = Rx<Dossier?>(null);

  @override
  void onInit() {
    super.onInit();
    
    // Récupère l'objet 'Dossier' qui a été passé en argument lors de la navigation.
    final dynamic argument = Get.arguments;
    
    // Vérifie si l'argument est bien du type 'Dossier'.
    if (argument is Dossier) {
      // Si oui, on met à jour notre variable réactive.
      // La vue qui écoute (Obx) se reconstruira automatiquement pour afficher les détails.
      dossier.value = argument;
    } else {
      // Si aucun dossier n'a été passé (ce qui serait une erreur de navigation),
      // on peut afficher un message d'erreur et revenir en arrière.
      Get.snackbar("Erreur", "Impossible de charger les détails du dossier.");
      // On attend un court instant pour que la snackbar soit visible avant de fermer la page.
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.isSnackbarOpen) Get.back(); // Ferme la snackbar
        Get.back(); // Ferme la page de détails
      });
    }
  }
}