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
    final email = emailController.text.trim().toLowerCase();
    isPersonnel.value = personnelEmails.contains(email);
  }

  // Appelé par le bouton "Se Connecter"
  void login() async {
    if (loginFormKey.currentState!.validate()) {
      await _performLogin(emailController.text, passwordController.text);
    }
  }

  // Appelé par le bouton "S'inscrire"
  void register() async {
    if (registerFormKey.currentState!.validate()) {
      isLoading.value = true; // Démarre le chargement
      try {
        final success = await _authService.register(nameController.text, emailController.text, passwordController.text);
        if (success) {
          // Si l'inscription réussit, on lance la connexion interne
          await _performLogin(emailController.text, passwordController.text);
        } else {
          // Si l'inscription échoue, on arrête le chargement ici
          isLoading.value = false;
        }
      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Erreur", "Une erreur inattendue est survenue.");
      }
    }
  }

  // Méthode interne qui contient la logique de connexion et de redirection
  Future<void> _performLogin(String email, String password) async {
    isLoading.value = true;
    try {
      final success = await _authService.login(email, password);
      if (success) {
        // Attend que le rôle soit chargé depuis Firestore
        await Get.find<AuthService>().appUser.stream.firstWhere((user) => user != null);
        final Utilisateur? connectedUser = _authService.appUser.value;

        if (connectedUser != null) {
          _redirectUserByRole(connectedUser.role);
        } else {
          // Si le rôle n'est pas trouvé (très rare), on déconnecte
          await _authService.logout();
          Get.snackbar('Erreur Critique', 'Impossible de récupérer les informations du rôle utilisateur.');
        }
      }
    } finally {
      // Ce bloc s'exécute toujours, mais si la redirection a lieu, 
      // l'utilisateur ne verra pas le changement de 'isLoading'.
      // C'est une sécurité en cas d'échec.
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