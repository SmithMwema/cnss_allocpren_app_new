import 'package:get/get.dart';
import '../modele/dossier.dart';
import '../modele/notification.dart';
import '../routes/app_pages.dart';
import '../service/auth_service.dart';
import '../service/firestore_service.dart';

class AccueilCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestore = Get.find<FirestoreService>();

  var nomUtilisateur = ''.obs;
  var emailUtilisateur = ''.obs;
  
  final RxList<Dossier> listeDossiers = <Dossier>[].obs;
  var aDesNotificationsNonLues = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authService.firebaseUser, (user) {
      if (user != null) {
        _chargerInfosUtilisateur();
        chargerDonneesAccueil();
      } else {
        listeDossiers.clear();
        nomUtilisateur.value = '';
        emailUtilisateur.value = '';
      }
    });
  }

  void _chargerInfosUtilisateur() {
    if (_authService.user != null) {
      nomUtilisateur.value = _authService.user!.displayName ?? 'Utilisateur Inconnu';
      emailUtilisateur.value = _authService.user!.email ?? 'email@inconnu.com';
    }
  }

  // --- MÉTHODE MISE À JOUR AVEC DES MESSAGES DE DÉBOGAGE ---
  Future<void> chargerDonneesAccueil() async {
    final userId = _authService.user?.uid;
    if (userId == null) {
      print("CHARGEMENT ANNULÉ : L'UID de l'utilisateur est null.");
      isLoading.value = false; // Important d'arrêter le chargement ici aussi
      return;
    }
    
    isLoading.value = true;
    print("ACCUEIL_CTRL: Début du chargement pour l'UID : $userId");
    
    try {
      final resultats = await Future.wait([
        _firestore.recupererDossiersUtilisateur(userId),
        _firestore.recupererNotifications(userId),
      ]);

      final List<Dossier> dossiers = resultats[0] as List<Dossier>;
      final List<AppNotification> notifications = resultats[1] as List<AppNotification>;
      
      print("ACCUEIL_CTRL: Requête Firestore terminée.");
      print("ACCUEIL_CTRL: Nombre de dossiers trouvés : ${dossiers.length}");

      listeDossiers.assignAll(dossiers);
      aDesNotificationsNonLues.value = notifications.any((notif) => !notif.estLue);

    } catch (e, stackTrace) {
      Get.snackbar("Erreur Critique", "Impossible de charger les données. Voir la console pour les détails.");
      print("ERREUR FATALE DANS chargerDonneesAccueil: $e");
      print(stackTrace);
    } finally {
      isLoading.value = false;
      print("ACCUEIL_CTRL: Fin du chargement.");
    }
  }

  void allerVersNotifications() {
    Get.toNamed(AppPages.notifications);
  }
  
  void allerVersDeclaration() async {
    await Get.toNamed(AppPages.declaration);
    chargerDonneesAccueil();
  }

  Future<void> seDeconnecter() async {
    await _authService.logout();
    Get.offAllNamed(AppPages.auth);
  }
}