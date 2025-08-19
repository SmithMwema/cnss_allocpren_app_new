// lib/modele/listing.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  final String? id;
  final DateTime dateCreation;
  final String creeParId; // L'ID du directeur qui a créé le listing
  
  // --- LA PROPRIÉTÉ CLÉ, AVEC LE BON NOM ---
  // C'est cette ligne qui va corriger les erreurs dans vos deux vues.
  final List<String> dossierIds; 
  
  String statut; // Ex: 'Généré', 'Payé'

  Listing({
    this.id,
    required this.dateCreation,
    required this.creeParId,
    required this.dossierIds, // Le nom est maintenant correct
    this.statut = 'Généré',
  });

  /// Méthode pour convertir l'objet Listing en un format compatible avec Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'dateCreation': Timestamp.fromDate(dateCreation),
      'creeParId': creeParId,
      'dossierIds': dossierIds, // Le nom est maintenant correct
      'statut': statut,
    };
  }

  /// Factory constructor pour créer une instance de Listing à partir d'un document Firestore.
  factory Listing.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    
    if (data == null) {
      throw StateError("Données manquantes dans le document Firestore: ${doc.id}");
    }

    return Listing(
      id: doc.id,
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      creeParId: data['creeParId'] ?? '',
      // Le nom est maintenant correct
      dossierIds: List<String>.from(data['dossierIds'] ?? []), 
      statut: data['statut'] ?? 'Généré',
    );
  }
}