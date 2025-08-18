import 'package:get/get.dart';

class Validateur {
  
  // --- NOUVELLE MÉTHODE AJOUTÉE ICI ---
  static String? validerTelephone(String? value) {
    if (value == null || value.trim().isEmpty) {
      // Pour le téléphone de l'assuré, il est obligatoire, donc on garde cette vérification.
      return 'Ce champ est obligatoire.';
    }
    // GetUtils.isNumericOnly vérifie si la chaîne ne contient que des chiffres.
    if (!GetUtils.isNumericOnly(value.trim())) {
      return 'Ce champ ne doit contenir que des chiffres.';
    }
    // On vérifie la longueur.
    if (value.trim().length != 10) {
      return 'Le numéro de téléphone doit contenir 10 chiffres.';
    }
    // Si toutes les vérifications passent, on ne retourne rien (pas d'erreur).
    return null;
  }
  // ------------------------------------

  static String? validerChampObligatoire(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire.';
    }
    return null;
  }

  static String? validerEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une adresse email.';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Veuillez entrer une adresse email valide.';
    }
    return null;
  }

  static String? validerMotDePasse(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe.';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    return null;
  }
}