// lib/modèle/dossier.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Dossier {
  final String? id;
  final String userId;
  String statut;

  // --- Champs de l'étape 1 : Assurée ---
  final String nomAssure;
  final String prenomAssure;
  final String etatCivilAssure;
  final String numSecuAssure;
  final String adresseAssure;
  final String emailAssure;
  final String telAssure;
  final String employeurAssure;
  final String numAffiliationEmployeur;
  final String adresseEmployeur;

  // --- Champs de l'étape 2 : Bénéficiaire (Optionnels) ---
  final String? nomBeneficiaire;
  final String? prenomBeneficiaire; 
  final DateTime? dateNaissanceBeneficiaire;

  // --- Champs de l'étape 3 : Infos Médicales ---
  final DateTime datePrevueAccouchement;
  final String nomFichierMedical;

  // --- Champs de suivi ---
  final DateTime dateSoumission;
  DateTime? dateMiseAJour;
  String? motifRejet;

  Dossier({
    this.id,
    required this.userId,
    this.statut = 'Soumis',
    required this.nomAssure,
    required this.prenomAssure,
    required this.etatCivilAssure,
    required this.numSecuAssure,
    required this.adresseAssure,
    required this.emailAssure,
    required this.telAssure,
    required this.employeurAssure,
    required this.numAffiliationEmployeur,
    required this.adresseEmployeur,
    this.nomBeneficiaire,
    this.prenomBeneficiaire,
    this.dateNaissanceBeneficiaire,
    required this.datePrevueAccouchement,
    required this.nomFichierMedical,
    required this.dateSoumission,
    this.dateMiseAJour,
    this.motifRejet,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'statut': statut,
      'nomAssure': nomAssure,
      'prenomAssure': prenomAssure,
      'etatCivilAssure': etatCivilAssure,
      'numSecuAssure': numSecuAssure,
      'adresseAssure': adresseAssure,
      'emailAssure': emailAssure,
      'telAssure': telAssure,
      'employeurAssure': employeurAssure,
      'numAffiliationEmployeur': numAffiliationEmployeur,
      'adresseEmployeur': adresseEmployeur,
      'nomBeneficiaire': nomBeneficiaire,
      'prenomBeneficiaire': prenomBeneficiaire,
      'dateNaissanceBeneficiaire': dateNaissanceBeneficiaire != null ? Timestamp.fromDate(dateNaissanceBeneficiaire!) : null,
      'datePrevueAccouchement': Timestamp.fromDate(datePrevueAccouchement),
      'nomFichierMedical': nomFichierMedical,
      'dateSoumission': Timestamp.fromDate(dateSoumission),
      'dateMiseAJour': dateMiseAJour != null ? Timestamp.fromDate(dateMiseAJour!) : null,
      'motifRejet': motifRejet,
    };
  }

  // --- CORRECTION APPLIQUÉE ICI ---
  factory Dossier.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data();
    if (data == null) {
      throw StateError("Le document ${doc.id} est vide ou n'existe pas !");
    }

    // Fonction d'aide pour convertir les dates de manière sécurisée
    DateTime? safeParseDate(dynamic dateData) {
      if (dateData == null) return null;
      if (dateData is Timestamp) return dateData.toDate();
      if (dateData is DateTime) return dateData; // L'utilise directement si c'est déjà un DateTime
      return null; // Retourne null si le format est inconnu
    }
    
    return Dossier(
      id: doc.id,
      userId: data['userId'] ?? '',
      statut: data['statut'] ?? 'Inconnu',
      nomAssure: data['nomAssure'] ?? '',
      prenomAssure: data['prenomAssure'] ?? '',
      etatCivilAssure: data['etatCivilAssure'] ?? '',
      numSecuAssure: data['numSecuAssure'] ?? '',
      adresseAssure: data['adresseAssure'] ?? '',
      emailAssure: data['emailAssure'] ?? '',
      telAssure: data['telAssure'] ?? '',
      employeurAssure: data['employeurAssure'] ?? '',
      numAffiliationEmployeur: data['numAffiliationEmployeur'] ?? '',
      adresseEmployeur: data['adresseEmployeur'] ?? '',
      nomBeneficiaire: data['nomBeneficiaire'] as String?,
      prenomBeneficiaire: data['prenomBeneficiaire'] as String?,
      
      // Utilisation de la fonction d'aide pour toutes les dates
      dateNaissanceBeneficiaire: safeParseDate(data['dateNaissanceBeneficiaire']),
      datePrevueAccouchement: safeParseDate(data['datePrevueAccouchement']) ?? DateTime.now(), // Valeur par défaut si nulle
      nomFichierMedical: data['nomFichierMedical'] ?? '',
      dateSoumission: safeParseDate(data['dateSoumission']) ?? DateTime.now(), // Valeur par défaut si nulle
      dateMiseAJour: safeParseDate(data['dateMiseAJour']),
      motifRejet: data['motifRejet'] as String?,
    );
  }
}