import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/auth_service.dart';
import '../service/firestore_service.dart';

// --- IMPORT MANQUANT AJOUTÉ ICI ---
import 'admin_dashboard_ctrl.dart';

class AdminAddUserCtrl extends GetxController {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final rolesDisponibles = ['Sélectionner un rôle', 'agent', 'directeur', 'caissier', 'admin'];
  var selectedRole = 'Sélectionner un rôle'.obs;

  Future<void> creerComptePersonnel() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        final userCredential = await _authService.adminCreateUser(
          emailController.text,
          passwordController.text,
          nameController.text,
        );

        if (userCredential?.user != null) {
          await _firestore.createUserDocument(
            userCredential!.user!.uid,
            nameController.text,
            emailController.text,
            selectedRole.value,
          );
          
          // Cette ligne est maintenant valide car le contrôleur est connu
          if (Get.isRegistered<AdminDashboardCtrl>()) {
            Get.find<AdminDashboardCtrl>().chargerToutesLesDonnees();
          }

          Get.back();
          Get.snackbar("Succès", "Le compte pour ${nameController.text} a été créé.");
        }
        
      } finally {
        isLoading.value = false;
      }
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