// lib/controleur/caissier_dashboard_ctrl.dart

import 'package:get/get.dart';
import '../modele/listing.dart';
import '../routes/app_pages.dart';
import '../service/auth_service.dart';
import '../service/firestore_service.dart';

class CaissierDashboardCtrl extends GetxController {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  // --- VARIABLES OBSERVABLES ---
  var isLoading = true.obs;
  
  // NOUVEAU : La variable principale est maintenant une liste de Listings
  final RxList<Listing> listeListings = <Listing>[].obs;
  
  // Données de l'utilisateur pour l'affichage (ex: dans le menu)
  final RxString nomUtilisateur = ''.obs;
  final RxString emailUtilisateur = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // On récupère les informations de l'utilisateur connecté
    _chargerInfosUtilisateur();

    // On lie la liste des listings au flux de données de Firestore
    listeListings.bindStream(
      _firestore.getListingsStream()
    );

    // On écoute le premier chargement de la liste pour masquer l'indicateur
    ever(listeListings, (_) {
      if (isLoading.value) {
        isLoading.value = false;
      }
    });
  }

  void _chargerInfosUtilisateur() {
    final user = _authService.user;
    if (user != null) {
      // Pour le caissier, le nom n'est pas dans Firestore, on peut utiliser un nom générique ou l'email
      nomUtilisateur.value = user.displayName ?? 'Caissier';
      emailUtilisateur.value = user.email ?? 'Email non disponible';
    }
  }
  
  /// Permet à la vue d'appeler cette fonction pour un rafraîchissement manuel.
  Future<void> chargerDonnees() async {
    // Aucune action n'est nécessaire car bindStream gère déjà les mises à jour.
  }
  
  /// Navigue vers la page de détails d'un listing spécifique.
  void voirDetailsListing(Listing listing) {
    // Il faudra créer une page de détails spécifique pour le caissier
    // Pour l'instant, on simule en affichant une boîte de dialogue
    Get.defaultDialog(
      title: "Navigation (Simulation)",
      middleText: "Ouverture de la page de détails pour le Listing ${listing.id}",
      textConfirm: "OK",
      onConfirm: () => Get.back(),
    );
  }
  
  /// Déconnecte l'utilisateur
  Future<void> seDeconnecter() async {
    await _authService.logout();
    Get.offAllNamed(AppPages.auth);
  }
}