// lib/controleur/accueil_ctrl.dart

import 'package:get/get.dart';
import '../modele/dossier.dart';
import '../modele/notification.dart';
import '../modele/utilisateur.dart';
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
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    
    ever(_authService.appUser, (Utilisateur? utilisateur) {
      if (utilisateur != null) {
        _chargerInfosUtilisateur(utilisateur);
        chargerDonneesAccueil();
      } else {
        _viderDonneesUtilisateur();
      }
    });

    if (_authService.appUser.value != null) {
      _chargerInfosUtilisateur(_authService.appUser.value!);
      chargerDonneesAccueil();
    }
  }

  void _chargerInfosUtilisateur(Utilisateur utilisateur) {
    nomUtilisateur.value = utilisateur.nom;
    emailUtilisateur.value = utilisateur.email;
  }

  void _viderDonneesUtilisateur() {
    nomUtilisateur.value = '';
    emailUtilisateur.value = '';
    listeDossiers.clear();
    aDesNotificationsNonLues.value = false;
  }

  Future<void> chargerDonneesAccueil() async {
    isLoading.value = true;
    
    final userId = _authService.appUser.value?.uid;
    if (userId == null) {
      isLoading.value = false;
      return;
    }
    
    try {
      final List<Dossier> dossiers = await _firestore.recupererDossiersUtilisateur(userId);
      final List<AppNotification> notifications = await _firestore.recupererNotifications(userId);
      
      listeDossiers.assignAll(dossiers);
      aDesNotificationsNonLues.value = notifications.any((notif) => !notif.estLue);

    } catch (e, stackTrace) {
      Get.snackbar("Erreur", "Impossible de charger l'historique des déclarations.");
      print("ERREUR CRITIQUE DANS chargerDonneesAccueil: $e");
      print(stackTrace);
      listeDossiers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void allerVersNotifications() {
    Get.toNamed(AppPages.notifications);
  }
  
  void allerVersDeclaration() async {
    await Get.toNamed(AppPages.declaration);
    chargerDonneesAccueil();
  }

  // --- NOUVELLE MÉTHODE AJOUTÉE ICI ---
  /// Navigue vers la page de détails du dossier sélectionné.
  void allerVersDetailsDossier(Dossier dossier) {
    // On utilise la nouvelle route que nous avons définie dans app_pages.dart
    // On passe l'objet 'dossier' complet en argument à la page de détails.
    Get.toNamed(AppPages.beneficiaireDetailsDossier, arguments: dossier);
  }
  // --- FIN DE L'AJOUT ---

  Future<void> seDeconnecter() async {
    await _authService.logout();
    Get.offAllNamed(AppPages.auth);
  }
}