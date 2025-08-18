import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controleur/admin_add_user_ctrl.dart';
import '../../utilitaire/validateur.dart';

// --- CORRECTION : ON HÉRITE BIEN DE STATELESSWIDGET ---
class AdminAddUserVue extends StatelessWidget {
  const AdminAddUserVue({super.key});

  @override
  Widget build(BuildContext context) {
    // On utilise Get.find() car le controleur est créé par le binding dans app_pages.dart
    final AdminAddUserCtrl ctrl = Get.find<AdminAddUserCtrl>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un Compte Personnel"),
        backgroundColor: const Color(0xff1b263b),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: ctrl.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Informations du Compte",
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: ctrl.nameController,
                decoration: const InputDecoration(labelText: "Nom complet", border: OutlineInputBorder()),
                validator: Validateur.validerChampObligatoire,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: ctrl.emailController,
                decoration: const InputDecoration(labelText: "Email de connexion", border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: Validateur.validerEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: ctrl.passwordController,
                decoration: const InputDecoration(labelText: "Mot de passe initial", border: OutlineInputBorder()),
                obscureText: true,
                validator: Validateur.validerMotDePasse,
              ),
              const SizedBox(height: 24),
              Text("Assigner un Rôle", style: GoogleFonts.poppins(fontSize: 18)),
              Obx(() => DropdownButtonFormField<String>(
                    value: ctrl.selectedRole.value,
                    items: ctrl.rolesDisponibles.map((String role) {
                      return DropdownMenuItem<String>(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) ctrl.selectedRole.value = newValue;
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (value) => value == 'Sélectionner un rôle' ? 'Veuillez choisir un rôle.' : null,
                  )),
              const SizedBox(height: 40),
              Obx(() => ElevatedButton.icon(
                    icon: ctrl.isLoading.value 
                        ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Icon(Icons.person_add),
                    label: Text(ctrl.isLoading.value ? 'Création en cours...' : 'Créer le Compte'),
                    onPressed: ctrl.isLoading.value ? null : ctrl.creerComptePersonnel,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Get.theme.colorScheme.secondary,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}