// lib/service/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modele/dossier.dart';
import '../modele/utilisateur.dart';
import '../modele/notification.dart';

class FirestoreService {
  
  final CollectionReference<Map<String, dynamic>> _dossiersCollection = 
      FirebaseFirestore.instance.collection('dossiers');
  final CollectionReference<Map<String, dynamic>> _utilisateursCollection = 
      FirebaseFirestore.instance.collection('utilisateurs');
  final CollectionReference<Map<String, dynamic>> _notificationsCollection = 
      FirebaseFirestore.instance.collection('notifications');

  // --- MÉTHODES UTILISATEURS ---

  Future<void> createUserDocument(String uid, String nom, String email, String role) async {
    final nouvelUtilisateur = Utilisateur(uid: uid, nom: nom, email: email, role: role);
    await _utilisateursCollection.doc(uid).set(nouvelUtilisateur.toFirestore());
  }

  Future<Utilisateur?> getUserDocument(String uid) async {
    final docSnapshot = await _utilisateursCollection.doc(uid).get();
    if (docSnapshot.exists) {
      return Utilisateur.fromFirestore(docSnapshot);
    }
    return null;
  }

  Future<List<Utilisateur>> recupererTousLesUtilisateurs() async {
    final snapshot = await _utilisateursCollection.get();
    return snapshot.docs.map((doc) => Utilisateur.fromFirestore(doc)).toList();
  }
  
  // --- MÉTHODES DOSSIERS ---

  Stream<List<Dossier>> getDossiersParStatutStream(String statut) {
    return _dossiersCollection
        .where('statut', isEqualTo: statut)
        .orderBy('dateSoumission', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Dossier.fromFirestore(doc))
            .toList());
  }

  Stream<List<Dossier>> getDossiersStreamParStatuts(List<String> statuts) {
    return _dossiersCollection
        .where('statut', whereIn: statuts)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) => Dossier.fromFirestore(doc)).toList();
          docs.sort((a, b) => b.dateSoumission.compareTo(a.dateSoumission));
          return docs;
        });
  }
  
  // --- MÉTHODE RESTAURÉE ---
  Stream<List<Dossier>> getDossiersStream() {
    return _dossiersCollection
        .orderBy('dateSoumission', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Dossier.fromFirestore(doc))
            .toList());
  }

  Future<void> soumettreNouveauDossier(Dossier dossier) async {
    await _dossiersCollection.add(dossier.toFirestore());
  }

  Future<List<Dossier>> recupererTousLesDossiers() async {
    final snapshot = await _dossiersCollection.orderBy('dateSoumission', descending: true).get();
    return snapshot.docs.map((doc) => Dossier.fromFirestore(doc)).toList();
  }

  Future<List<Dossier>> recupererDossiersUtilisateur(String userId) async {
    final snapshot = await _dossiersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('dateSoumission', descending: true)
        .get();
    return snapshot.docs.map((doc) => Dossier.fromFirestore(doc)).toList();
  }
  
  Future<void> updateDossierStatus(String dossierId, String nouveauStatut, {String? motif}) async {
    final Map<String, dynamic> dataToUpdate = {
      'statut': nouveauStatut,
      'dateMiseAJour': Timestamp.now(),
    };

    if (motif != null && motif.isNotEmpty) {
      dataToUpdate['motifRejet'] = motif;
    }

    await _dossiersCollection.doc(dossierId).update(dataToUpdate);
  }

  Future<Dossier?> recupererDossierParId(String dossierId) async {
    final docSnapshot = await _dossiersCollection.doc(dossierId).get();
    if (docSnapshot.exists) {
      return Dossier.fromFirestore(docSnapshot);
    }
    return null;
  }

  // --- MÉTHODES NOTIFICATIONS ---

  Future<void> envoyerNotification(AppNotification notification) async {
    await _notificationsCollection.add(notification.toFirestore());
  }

  Future<List<AppNotification>> recupererNotifications(String userId) async {
    final snapshot = await _notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('dateCreation', descending: true)
        .get();
    return snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList();
  }

  Future<void> marquerNotificationCommeLue(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({'estLue': true});
  }
}