// lib/controleur/auth_ctrl.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modele/utilisateur.dart';
import '../routes/app_pages.dart';
import '../service/auth_service.dart';

enum AuthMode { login, register, reset }

class AuthCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var authMode = AuthMode.login.obs;
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var isPersonnel = false.obs;

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();

  late TextEditingController emailController, passwordController, nameController, confirmPasswordController;

  final List<String> personnelEmails = ['agent@cnss.cd', 'directeur@cnss.cd', 'caissier@cnss.cd', 'admin@cnss.cd'];

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    confirmPasswordController = TextEditingController();
    emailController.addListener(checkIfPersonnel);
  }

  void checkIfPersonnel() {
    isPersonnel.value = personnelEmails.contains(emailController.text.trim().toLowerCase());
  }

  void login() async {
    if (loginFormKey.currentState!.validate()) {
      await _performLogin(emailController.text, passwordController.text);
    }
  }

  // --- LOGIQUE D'INSCRIPTION CORRIGÉE ET SIMPLIFIÉE ---
  void register() async {
    if (registerFormKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        // On appelle la nouvelle méthode robuste du service
        final success = await _authService.registerUser(
          nameController.text,
          emailController.text,
          passwordController.text,
        );
        
        // Si l'inscription a réussi, Firebase mettra automatiquement l'utilisateur à l'état "connecté".
        // Notre listener dans AuthService s'occupera de charger les données et de rediriger.
        // Nous n'avons plus besoin d'appeler _performLogin ici.
        // La redirection se fera automatiquement via un autre mécanisme (voir le AuthWrapper/Splash screen).
        
        // Pour une redirection immédiate si aucun wrapper n'est en place :
        if (success) {
          await Get.find<AuthService>().appUser.stream.firstWhere((user) => user != null);
          final Utilisateur? newUser = _authService.appUser.value;
          if (newUser != null) {
            _redirectUserByRole(newUser.role);
          }
        }
      } finally {
        // On s'assure que le chargement s'arrête, quoi qu'il arrive.
        isLoading.value = false;
      }
    }
  }

  Future<void> _performLogin(String email, String password) async {
    isLoading.value = true;
    try {
      final success = await _authService.login(email, password);
      if (success) {
        await Get.find<AuthService>().appUser.stream.firstWhere((user) => user != null);
        final Utilisateur? connectedUser = _authService.appUser.value;

        if (connectedUser != null) {
          _redirectUserByRole(connectedUser.role);
        } else {
          await _authService.logout();
          Get.snackbar('Erreur Critique', 'Impossible de récupérer les informations du rôle utilisateur.');
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _redirectUserByRole(String role) {
    switch (role) {
      case 'agent': Get.offAllNamed(AppPages.agentDashboard); break;
      case 'directeur': Get.offAllNamed(AppPages.directeurDashboard); break;
      case 'caissier': Get.offAllNamed(AppPages.caissierDashboard); break;
      case 'admin': Get.offAllNamed(AppPages.adminDashboard); break;
      case 'beneficiaire':
      default: Get.offAllNamed(AppPages.accueil);
    }
  }

  void resetPassword() async {
    if (resetFormKey.currentState!.validate()) {
      isLoading.value = true;
      await _authService.resetPassword(emailController.text);
      isLoading.value = false;
      Get.snackbar('Succès', 'Si un compte existe, un email a été envoyé.');
      switchToLogin();
    }
  }

  void switchToRegister() { _clearControllers(); authMode.value = AuthMode.register; }
  void switchToLogin() { _clearControllers(); authMode.value = AuthMode.login; }
  void switchToReset() { _clearControllers(); authMode.value = AuthMode.reset; }

  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    emailController.removeListener(checkIfPersonnel);
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}