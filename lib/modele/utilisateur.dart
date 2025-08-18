// lib/modèle/utilisateur.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Utilisateur {
  final String uid;
  final String nom;
  final String email;
  final String role;

  Utilisateur({
    required this.uid,
    required this.nom,
    required this.email,
    required this.role,
  });

  // CORRECTION : Renommé 'toMap' en 'toFirestore' pour la cohérence du projet.
  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'email': email,
      'role': role,
      // Note : L'UID n'est pas stocké ici car il est l'ID du document.
    };
  }

  // Crée un objet Utilisateur à partir d'un document Firestore
  factory Utilisateur.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError("Le document utilisateur ${doc.id} est vide !");
    }
    
    return Utilisateur(
      uid: doc.id,
      nom: data['nom'] ?? 'Nom non trouvé',
      email: data['email'] ?? 'Email non trouvé',
      // Fournit un rôle par défaut sécurisé si non trouvé
      role: data['role'] ?? 'beneficiaire',
    );
  }
}