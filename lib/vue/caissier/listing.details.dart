// Code corrigé et complet pour : lib/modele/listing.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORTANT : Le nom de la classe est DossierDansListing, et non DossierPaiement
class DossierDansListing {
  final String dossierId;
  String statutPaiement; // ex: 'En attente', 'Payé'

  DossierDansListing({required this.dossierId, this.statutPaiement = 'En attente'});

  // Conversion pour Firestore
  Map<String, dynamic> toMap() => {'dossierId': dossierId, 'statutPaiement': statutPaiement};
  factory DossierDansListing.fromMap(Map<String, dynamic> map) {
    return DossierDansListing(
      dossierId: map['dossierId'] ?? '',
      statutPaiement: map['statutPaiement'] ?? 'En attente',
    );
  }
}

class Listing {
  final String? id;
  final DateTime dateCreation;
  String statut; // ex: 'En attente de paiement', 'Partiellement Payé', 'Payé'
  
  // CHAMP MANQUANT AJOUTÉ ICI
  final List<DossierDansListing> dossiers;

  Listing({
    this.id,
    required this.dateCreation,
    required this.statut,
    required this.dossiers, // Ajouté au constructeur
  });

  // Conversion pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'dateCreation': Timestamp.fromDate(dateCreation),
      'statut': statut,
      'dossiers': dossiers.map((d) => d.toMap()).toList(), // On convertit la liste
    };
  }

  factory Listing.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception("Document de listing vide !");
    
    // On s'assure que 'dossiers' est bien une liste avant de la mapper
    final dossiersData = data['dossiers'] as List<dynamic>? ?? [];
    
    return Listing(
      id: doc.id,
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      statut: data['statut'] ?? 'Statut inconnu',
      // On convertit la liste depuis Firestore
      dossiers: dossiersData
          .map((item) => DossierDansListing.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}