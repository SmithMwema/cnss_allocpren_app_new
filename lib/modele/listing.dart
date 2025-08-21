// lib/modèle/listing.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DossierPaiement {
  final String dossierId;
  String statutPaiement;

  DossierPaiement({required this.dossierId, this.statutPaiement = 'En attente'});

  factory DossierPaiement.fromMap(Map<String, dynamic> map) {
    return DossierPaiement(
      dossierId: map['dossierId'] ?? '',
      statutPaiement: map['statutPaiement'] ?? 'En attente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dossierId': dossierId,
      'statutPaiement': statutPaiement,
    };
  }
}

class Listing {
  final String? id;
  final DateTime dateCreation;
  final String creeParId;
  final List<DossierPaiement> dossiers; // Le champ correct
  String statut;

  Listing({
    this.id,
    required this.dateCreation,
    required this.creeParId,
    required this.dossiers, // Le constructeur correct
    this.statut = 'Généré',
  });

  Map<String, dynamic> toFirestore() {
    return {
      'dateCreation': Timestamp.fromDate(dateCreation),
      'creeParId': creeParId,
      'dossiers': dossiers.map((d) => d.toMap()).toList(),
      'statut': statut,
    };
  }

  factory Listing.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Listing(
      id: doc.id,
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      creeParId: data['creeParId'] as String,
      dossiers: (data['dossiers'] as List<dynamic>?)
          ?.map((item) => DossierPaiement.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      statut: data['statut'] as String,
    );
  }
}