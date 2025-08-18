import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart'; // <<<--- IMPORT MANQUANT AJOUTÉ ICI
import '../modele/utilisateur.dart';
import 'firestore_service.dart';

class AuthService extends GetxController {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = Get.find<FirestoreService>();

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<Utilisateur?> appUser = Rx<Utilisateur?>(null);

  User? get user => firebaseUser.value;
  bool get estUtilisateurConnecte => user != null;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _loadAppUser);
  }

  _loadAppUser(User? fUser) async {
    if (fUser != null) {
      appUser.value = await _firestore.getUserDocument(fUser.uid);
    } else {
      appUser.value = null;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Erreur de connexion', e.message ?? 'Une erreur est survenue.');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      UserCredential uc = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await uc.user?.updateDisplayName(name);
      await _firestore.createUserDocument(uc.user!.uid, name, email, 'beneficiaire');
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Erreur d\'inscription', e.message ?? 'Une erreur est survenue.');
      return false;
    }
  }
  
  Future<UserCredential?> adminCreateUser(String email, String password, String name) async {
    try {
      // Cette ligne est maintenant valide car Firebase est connu
      final tempApp = await Firebase.initializeApp(
        name: 'tempAdminCreation_${DateTime.now().millisecondsSinceEpoch}', 
        options: Firebase.app().options
      );
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      UserCredential uc = await tempAuth.createUserWithEmailAndPassword(email: email, password: password);
      await uc.user?.updateDisplayName(name);
      
      await tempApp.delete();
      
      return uc;

    } on FirebaseAuthException catch (e) {
      Get.snackbar('Erreur de création (Auth)', e.message ?? 'Une erreur est survenue.');
      return null;
    }
  }
  
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Email envoyé', 'Si un compte existe, un lien de réinitialisation a été envoyé.');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Erreur', e.message ?? 'Une erreur est survenue.');
    }
  }
}