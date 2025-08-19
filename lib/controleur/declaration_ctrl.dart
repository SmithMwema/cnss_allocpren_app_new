// lib/controleur/declaration_ctrl.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../modele/dossier.dart';
import '../service/auth_service.dart';
import '../service/firestore_service.dart';
import '../utilitaire/validateur.dart';

class DeclarationCtrl extends GetxController {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final formKeyEtape1 = GlobalKey<FormState>();
  final formKeyEtape2 = GlobalKey<FormState>();
  var currentStep = 0.obs;

  // --- Controleurs pour TOUS les champs ---
  final nomAssureCtrl = TextEditingController();
  final prenomAssureCtrl = TextEditingController();
  final etatCivilAssureCtrl = TextEditingController();
  final numSecuAssureCtrl = TextEditingController();
  final adresseAssureCtrl = TextEditingController();
  final emailAssureCtrl = TextEditingController();
  final telAssureCtrl = TextEditingController();
  final employeurAssureCtrl = TextEditingController();
  final numAffiliationEmployeurCtrl = TextEditingController();
  final adresseEmployeurCtrl = TextEditingController();
  final nomBeneficiaireCtrl = TextEditingController();
  final prenomBeneficiaireCtrl = TextEditingController(); 
  final dateNaissanceBeneficiaireCtrl = TextEditingController();
  final datePrevueAccouchementCtrl = TextEditingController();
  
  // --- Variables pour les dates et fichiers ---
  DateTime? _dateNaissanceBeneficiaire;
  DateTime? _dateAccouchement;
  var nomFichierSelectionne = ''.obs;

  @override
  void onClose() {
    // Nettoyer tous les controleurs
    nomAssureCtrl.dispose(); prenomAssureCtrl.dispose(); etatCivilAssureCtrl.dispose();
    numSecuAssureCtrl.dispose(); adresseAssureCtrl.dispose(); emailAssureCtrl.dispose();
    telAssureCtrl.dispose(); employeurAssureCtrl.dispose(); numAffiliationEmployeurCtrl.dispose();
    adresseEmployeurCtrl.dispose(); nomBeneficiaireCtrl.dispose();
    prenomBeneficiaireCtrl.dispose(); 
    dateNaissanceBeneficiaireCtrl.dispose(); datePrevueAccouchementCtrl.dispose();
    super.onClose();
  }

  /// Ouvre le sélecteur de date pour la naissance de la bénéficiaire
  Future<void> choisirDateNaissanceBeneficiaire(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context, initialDate: _dateNaissanceBeneficiaire ?? DateTime.now(),
      firstDate: DateTime(1940), lastDate: DateTime.now(), locale: const Locale('fr', 'FR'),
    );
    if (date != null) {
      _dateNaissanceBeneficiaire = date;
      dateNaissanceBeneficiaireCtrl.text = DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
    }
  }

  /// Ouvre le sélecteur de date pour la date d'accouchement
  Future<void> choisirDatePrevueAccouchement(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context, initialDate: _dateAccouchement ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 300)),
      lastDate: DateTime.now().add(const Duration(days: 300)),
      locale: const Locale('fr', 'FR'),
    );
    if (date != null) {
      _dateAccouchement = date;
      datePrevueAccouchementCtrl.text = DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
    }
  }

  /// Simule la sélection d'un fichier.
  Future<void> selectionnerFichier() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf', 'png', 'jpg'],
    );
    if (result != null) {
      nomFichierSelectionne.value = result.files.single.name;
    }
  }

  /// Gère la soumission du formulaire final
  void soumettreDeclaration() async {
    if (!formKeyEtape1.currentState!.validate()) {
        Get.snackbar("Champs Incomplets", "Veuillez vérifier les informations de l'assurée (Étape 1).",
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
    }
    if (_dateAccouchement == null) {
        Get.snackbar("Information Manquante", "Veuillez indiquer la date prévue d'accouchement (Étape 3).",
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
    }
    if (nomFichierSelectionne.value.isEmpty) {
      Get.snackbar("Pièce jointe manquante", "Veuillez joindre le certificat médical (Étape 3).",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    
    try {
      final nouveauDossier = Dossier(
        userId: _authService.user!.uid,
        dateSoumission: DateTime.now(),
        statut: "Soumis",
        nomAssure: nomAssureCtrl.text.trim(),
        prenomAssure: prenomAssureCtrl.text.trim(),
        etatCivilAssure: etatCivilAssureCtrl.text.trim(),
        numSecuAssure: numSecuAssureCtrl.text.trim(),
        adresseAssure: adresseAssureCtrl.text.trim(),
        emailAssure: emailAssureCtrl.text.trim(),
        telAssure: telAssureCtrl.text.trim(),
        employeurAssure: employeurAssureCtrl.text.trim(),
        numAffiliationEmployeur: numAffiliationEmployeurCtrl.text.trim(),
        adresseEmployeur: adresseEmployeurCtrl.text.trim(),
        nomBeneficiaire: nomBeneficiaireCtrl.text.trim().isNotEmpty ? nomBeneficiaireCtrl.text.trim() : null,
        prenomBeneficiaire: prenomBeneficiaireCtrl.text.trim().isNotEmpty ? prenomBeneficiaireCtrl.text.trim() : null,
        dateNaissanceBeneficiaire: _dateNaissanceBeneficiaire,
        datePrevueAccouchement: _dateAccouchement!,
        nomFichierMedical: nomFichierSelectionne.value,
      );

      await _firestore.soumettreNouveauDossier(nouveauDossier);

      Get.back();
      Get.offAllNamed('/accueil');
      Get.snackbar("Succès", "Votre dossier a été soumis avec succès !",
          backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.back();
      Get.snackbar("Erreur", "L'envoi a échoué : ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void onStepContinue() {
    if (currentStep.value == 0) {
      if (formKeyEtape1.currentState!.validate()) {
         currentStep.value++;
      }
    } else if (currentStep.value == 1) {
      currentStep.value++;
    } else if (currentStep.value == 2) {
      soumettreDeclaration();
    }
  }

  void onStepCancel() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }
}