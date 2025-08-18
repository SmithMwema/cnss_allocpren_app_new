import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controleur/auth_ctrl.dart';
import '../utilitaire/validateur.dart';

class AuthVue extends GetView<AuthCtrl> {
  const AuthVue({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0d1b2a), Color(0xff1b263b), Color(0xff415a77)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
                },
                child: _buildForm(controller),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- CORRECTION : Suppression de la clause "default" inutile ---
  Widget _buildForm(AuthCtrl ctrl) {
    switch (ctrl.authMode.value) {
      case AuthMode.login:
        return _LoginForm(key: const ValueKey('login'));
      case AuthMode.register:
        return _RegisterForm(key: const ValueKey('register'));
      case AuthMode.reset:
        return _ResetPasswordForm(key: const ValueKey('reset'));
    }
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthCtrl ctrl = Get.find<AuthCtrl>();
    ctrl.emailController.addListener(() => ctrl.checkIfPersonnel());

    return Form(
      key: ctrl.loginFormKey,
      child: Column(
        children: [
          Icon(Icons.lock_person_outlined, size: 60, color: Colors.white.withAlpha(204)), // CORRECTION .withOpacity()
          const SizedBox(height: 20),
          Text("Connexion", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 30),
          _buildTextField(ctrl.emailController, "Email", Icons.email_outlined, validator: Validateur.validerEmail),
          const SizedBox(height: 16),
          _buildPasswordField(ctrl),
          const SizedBox(height: 20),
          _buildAuthButton("Se Connecter", ctrl.login, ctrl.isLoading),
          const SizedBox(height: 16),
          Obx(() {
            if (ctrl.isPersonnel.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Espace réservé au personnel de la CNSS.", style: TextStyle(color: Colors.white.withAlpha(178))), // CORRECTION .withOpacity()
              );
            } else {
              return Column(
                children: [
                  _buildSwitcher("Pas de compte ?", "S'inscrire", ctrl.switchToRegister),
                  _buildSwitcher("Mot de passe oublié ?", "Réinitialiser", ctrl.switchToReset),
                ],
              );
            }
          }),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthCtrl ctrl = Get.find<AuthCtrl>();
    return Form(
      key: ctrl.registerFormKey,
      child: Column(
        children: [
          Text("Créer un Compte", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 30),
           _buildTextField(ctrl.nameController, "Nom complet", Icons.person_outline, validator: Validateur.validerChampObligatoire),
          const SizedBox(height: 16),
          _buildTextField(ctrl.emailController, "Email", Icons.email_outlined, validator: Validateur.validerEmail),
          const SizedBox(height: 16),
          _buildPasswordField(ctrl),
          const SizedBox(height: 16),
           _buildTextField(ctrl.confirmPasswordController, "Confirmer mot de passe", Icons.lock_outline, isPassword: true, validator: (val){
              if(val == null || val.isEmpty) return 'Veuillez confirmer le mot de passe.';
              if(val != ctrl.passwordController.text) return 'Les mots de passe ne correspondent pas.';
              return null;
            }),
          const SizedBox(height: 20),
          _buildAuthButton("S'inscrire", ctrl.register, ctrl.isLoading),
          const SizedBox(height: 16),
          _buildSwitcher("Déjà un compte ?", "Se connecter", ctrl.switchToLogin),
        ],
      ),
    );
  }
}

class _ResetPasswordForm extends StatelessWidget {
  const _ResetPasswordForm({super.key});
  @override
  Widget build(BuildContext context) {
     final AuthCtrl ctrl = Get.find<AuthCtrl>();
    return Form(
      key: ctrl.resetFormKey,
      child: Column(
        children: [
          Text("Réinitialiser", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 30),
          _buildTextField(ctrl.emailController, "Votre Email", Icons.email_outlined, validator: Validateur.validerEmail),
          const SizedBox(height: 20),
          _buildAuthButton("Envoyer le lien", ctrl.resetPassword, ctrl.isLoading),
          const SizedBox(height: 16),
          _buildSwitcher("Retour à la", "Connexion", ctrl.switchToLogin),
        ],
      ),
    );
  }
}

Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, String? Function(String?)? validator}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    validator: validator,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withAlpha(178)), // CORRECTION .withOpacity()
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(128))), // CORRECTION .withOpacity()
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
    ),
  );
}

Widget _buildPasswordField(AuthCtrl ctrl) {
  return Obx(() => TextFormField(
    controller: ctrl.passwordController,
    obscureText: ctrl.isPasswordHidden.value,
    validator: Validateur.validerMotDePasse,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: "Mot de passe",
      labelStyle: TextStyle(color: Colors.white.withAlpha(178)), // CORRECTION .withOpacity()
      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
      suffixIcon: IconButton(
        icon: Icon(ctrl.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
        onPressed: () => ctrl.isPasswordHidden.toggle(),
      ),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withAlpha(128))), // CORRECTION .withOpacity()
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
    ),
  ));
}

Widget _buildAuthButton(String text, VoidCallback onPressed, RxBool isLoading) {
  return Obx(() => SizedBox(
    width: double.infinity,
    child: isLoading.value
      ? const Center(child: CircularProgressIndicator(color: Colors.white))
      : ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xff00a99d),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(text, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
  ));
}

Widget _buildSwitcher(String text1, String text2, VoidCallback onPressed) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text1, style: TextStyle(color: Colors.white.withAlpha(204))), // CORRECTION .withOpacity()
      TextButton(
        onPressed: onPressed,
        child: Text(text2, style: const TextStyle(color: Color(0xff00a99d), fontWeight: FontWeight.bold)),
      ),
    ],
  );
}