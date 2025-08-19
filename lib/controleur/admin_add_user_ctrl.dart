// lib/controleur/admin_add_user_ctrl.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/auth_service.dart';
import 'admin_dashboard_ctrl.dart';

class AdminAddUserCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final rolesDisponibles = ['Sélectionner un rôle', 'agent', 'directeur', 'caissier', 'admin'];
  var selectedRole = 'Sélectionner un rôle'.obs;

  Future<void> creerComptePersonnel() async {
    final isFormValid = formKey.currentState?.validate() ?? false;
    // CORRECTION : S'assurer que le nom de la chaîne correspond bien à la valeur par défaut
    final isRoleSelected = selectedRole.value != 'Sélectionner un rôle';

    if (!isFormValid) {
      Get.snackbar("Erreur", "Veuillez remplir tous les champs correctement.");
      return;
    }
    if (!isRoleSelected) {
      Get.snackbar("Erreur", "Veuillez sélectionner un rôle pour le nouvel utilisateur.");
      return;
    }

    isLoading.value = true;
    try {
      // --- CORRECTION APPLIQUÉE ICI ---
      // On appelle la méthode avec les 4 arguments dans le bon ordre.
      final bool success = await _authService.adminCreateUser(
        nameController.text,      // 1. name
        emailController.text,     // 2. email
        passwordController.text,  // 3. password
        selectedRole.value,       // 4. role
      );

      if (success) {
        // Rafraîchir la liste des utilisateurs dans le tableau de bord de l'admin
        if (Get.isRegistered<AdminDashboardCtrl>()) {
          Get.find<AdminDashboardCtrl>().chargerToutesLesDonnees();
        }

        Get.back(); // Ferme la page d'ajout
        Get.snackbar("Succès", "Le compte pour ${nameController.text} a été créé.",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
      // Si la création échoue, le AuthService affiche déjà le message d'erreur.

    } catch (e) {
      Get.snackbar("Erreur Inattendue", "Une erreur s'est produite: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}