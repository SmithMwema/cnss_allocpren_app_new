// lib/controleur/agent_details_dossier_ctrl.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// On importe les modeles dont ce controleur a besoin
import '../modele/dossier.dart';
import '../modele/notification.dart';

// Et les services
import '../service/firestore_service.dart';

class AgentDetailsDossierCtrl extends GetxController {
  // --- DÉPENDANCES ---
  final FirestoreService _firestore = Get.find<FirestoreService>();

  // --- ÉTAT (STATE) ---
  final Rx<Dossier?> dossier = Rx<Dossier?>(null);
  var isProcessing = false.obs;

  // --- GESTION DU FORMULAIRE DE REJET ---
  final rejetFormKey = GlobalKey<FormState>();
  final rejetMotifController = TextEditingController();

  // --- CYCLE DE VIE ---

  @override
  void onInit() {
    super.onInit();
    final dynamic argument = Get.arguments;
    if (argument is Dossier) {
      dossier.value = argument;
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (dossier.value == null) {
      Get.snackbar(
        "Erreur Critique",
        "Les données du dossier sont invalides.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });
    }
  }

  @override
  void onClose() {
    rejetMotifController.dispose();
    super.onClose();
  }

  // --- MÉTHODES D'ACTION ---

  /// Approuve le dossier et le transfère au directeur.
  void approuverDossier() {
    // Appel de la méthode centralisée
    _mettreAJourStatutDossier(
      nouveauStatut: 'Traité par Agent',
      messageSucces: 'Dossier approuvé et transféré au directeur.',
      messageNotification: 'Bonne nouvelle ! Votre dossier a été traité par notre agent et est en cours de validation.',
    );
  }

  /// Rejette le dossier après validation du motif.
  void rejeterDossier() {
    if (rejetFormKey.currentState?.validate() ?? false) {
      final motif = rejetMotifController.text;
      
      // Ferme le dialogue de saisie du motif
      if (Get.isDialogOpen ?? false) Get.back();

      // Appel de la méthode centralisée
      _mettreAJourStatutDossier(
        nouveauStatut: 'Rejeté',
        motif: motif,
        messageSucces: 'Le dossier a été rejeté et la bénéficiaire notifiée.',
        messageNotification: 'Votre dossier a été rejeté. Motif : "$motif". Veuillez consulter nos services pour plus de détails.',
      );
    }
  }

  // AMÉLIORATION : Méthode privée pour centraliser la logique de mise à jour.
  // Cela évite la duplication de code et rend les actions plus claires.
  Future<void> _mettreAJourStatutDossier({
    required String nouveauStatut,
    required String messageSucces,
    required String messageNotification,
    String? motif,
  }) async {
    // Vérification de sécurité
    if (dossier.value?.id == null || dossier.value?.userId == null) {
      Get.snackbar("Erreur", "ID du dossier ou de l'utilisateur manquant.");
      return;
    }

    isProcessing.value = true;
    
    try {
      // CORRECTION 1 : Utilisation de la méthode correcte `updateDossierStatus`
      await _firestore.updateDossierStatus(
        dossier.value!.id!,
        nouveauStatut,
        motif: motif, // Le motif est optionnel
      );

      // CORRECTION 2 & 3 : Création de la notification avec les bons paramètres
      final notification = AppNotification(
        userId: dossier.value!.userId,
        titre: "Mise à jour de votre dossier",
        message: messageNotification,
        dateCreation: DateTime.now(), // Utilise `dateCreation` et `DateTime`
        dossierId: dossier.value!.id,
      );
      await _firestore.envoyerNotification(notification);

      // Navigation et feedback utilisateur
      Get.back(); // Retourne à la liste des dossiers
      Get.snackbar("Succès", messageSucces,
          backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar("Erreur", "Une erreur est survenue : ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }
}