// lib/modèle/notification.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String? id;
  final String userId;        // À qui est destinée la notification
  final String titre;
  final String message;
  final DateTime dateCreation;
  final bool estLue;
  final String? dossierId;     // Champ optionnel pour lier à un dossier

  AppNotification({
    this.id,
    required this.userId,
    required this.titre,
    required this.message,
    required this.dateCreation,
    this.estLue = false,
    this.dossierId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'titre': titre,
      'message': message,
      'dateCreation': Timestamp.fromDate(dateCreation), 
      'estLue': estLue,
      if (dossierId != null) 'dossierId': dossierId,
    };
  }

  // --- CORRECTION APPLIQUÉE ICI ---
  factory AppNotification.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError("Le document de notification ${doc.id} est vide !");
    }

    // Fonction d'aide pour convertir les dates de manière sécurisée
    DateTime? safeParseDate(dynamic dateData) {
      if (dateData == null) return null;
      if (dateData is Timestamp) return dateData.toDate();
      if (dateData is DateTime) return dateData; // L'utilise directement
      return null;
    }

    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      titre: data['titre'] ?? 'Sans titre',
      message: data['message'] ?? '',
      // Utilisation de la fonction d'aide robuste
      dateCreation: safeParseDate(data['dateCreation']) ?? DateTime.now(),
      estLue: data['estLue'] ?? false,
      dossierId: data['dossierId'] as String?,
    );
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? titre,
    String? message,
    DateTime? dateCreation,
    bool? estLue,
    String? dossierId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titre: titre ?? this.titre,
      message: message ?? this.message,
      dateCreation: dateCreation ?? this.dateCreation,
      estLue: estLue ?? this.estLue,
      dossierId: dossierId ?? this.dossierId,
    );
  }
}