import 'dossier.dart';

class Listing {
  final String id;
  final DateTime dateCreation;
  final String creePar;
  final String statut;
  final List<Dossier> dossiers;

  Listing({
    required this.id,
    required this.dateCreation,
    required this.creePar,
    required this.statut,
    required this.dossiers,
  });

  // --- CORRECTION ---
  // On commente cette ligne pour l'instant, car le modèle 'Dossier'
  // n'a pas encore de champ 'montantAPayer'.
  // double get montantTotal {
  //   return dossiers.fold(0.0, (sum, item) => sum + item.montantAPayer);
  // }
}