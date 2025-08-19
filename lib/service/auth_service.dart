// lib/service/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../modele/utilisateur.dart';
import 'firestore_service.dart';

class AuthService extends GetxService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final Rx<Utilisateur?> appUser = Rx<Utilisateur?>(null);

  @override
  void onInit() {
    super.onInit();
    // Écoute les changements d'état de connexion de l'utilisateur
    _firebaseAuth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        // Si connecté, charge les infos depuis Firestore
        _firestoreService.getUserDocument(firebaseUser.uid).then((utilisateur) {
          appUser.value = utilisateur;
        });
      } else {
        // Si déconnecté, vide les infos
        appUser.value = null;
      }
    });
  }

  /// Inscription pour les BÉNÉFICIAIRES
  Future<bool> registerUser(String name, String email, String password) async {
    try {
      // Étape 1 : Créer dans Firebase Auth
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final String uid = userCredential.user!.uid;

      // Étape 2 : Créer dans Firestore
      await _firestoreService.createUserDocument(uid, name.trim(), email.trim(), 'beneficiaire');
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Erreur d'inscription", e.message ?? "Une erreur est survenue.");
      return false;
    }
  }
  
  /// Création de compte pour le PERSONNEL par un ADMIN
  Future<bool> adminCreateUser(String name, String email, String password, String role) async {
    // NOTE : Cette approche est une simplification. Pour une sécurité maximale,
    // la création d'utilisateurs devrait se faire via des Cloud Functions côté serveur.
    try {
      // Étape 1 : Créer le compte dans Firebase Authentication
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final String uid = userCredential.user!.uid;

      // Étape 2 : Créer le document dans Firestore avec le rôle assigné
      await _firestoreService.createUserDocument(uid, name.trim(), email.trim(), role);

      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Erreur de création", e.message ?? "Une erreur Firebase est survenue.");
      // Important : Si la création échoue, il faut supprimer l'utilisateur de Auth pour éviter les "fantômes"
      if (e.code == 'email-already-in-use') {
        // C'est une erreur "normale", on n'a rien à nettoyer.
      }
      return false;
    } catch (e) {
      Get.snackbar("Erreur Inattendue", "Impossible de créer l'utilisateur : $e");
      return false;
    }
  }

  /// Connexion pour TOUS les utilisateurs
  Future<bool> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Erreur de connexion", e.message ?? "Vérifiez vos identifiants.");
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Réinitialisation de mot de passe
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  /// Getters utiles
  User? get firebaseUser => _firebaseAuth.currentUser;
  User? get user => _firebaseAuth.currentUser;
}