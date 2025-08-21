// lib/service/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../modele/dossier.dart';
import '../modele/listing.dart';
import '../modele/utilisateur.dart';
import '../modele/notification.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  CollectionReference<Map<String, dynamic>> get _dossiersCollection => _db.collection('dossiers');
  CollectionReference<Map<String, dynamic>> get _utilisateursCollection => _db.collection('utilisateurs');
  CollectionReference<Map<String, dynamic>> get _notificationsCollection => _db.collection('notifications');
  CollectionReference<Map<String, dynamic>> get _listingsCollection => _db.collection('listings');

  // --- MÉTHODES UTILISATEURS ---
  Future<void> createUserDocument(String uid, String nom, String email, String role) async {
    final nouvelUtilisateur = Utilisateur(uid: uid, nom: nom, email: email, role: role);
    await _utilisateursCollection.doc(uid).set(nouvelUtilisateur.toFirestore());
  }
  Future<Utilisateur?> getUserDocument(String uid) async {
    final docSnapshot = await _utilisateursCollection.doc(uid).get();
    if (docSnapshot.exists) { return Utilisateur.fromFirestore(docSnapshot); }
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
        .map((snapshot) => snapshot.docs.map((doc) => Dossier.fromFirestore(doc)).toList());
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
  Stream<List<Dossier>> getDossiersStream() {
    return _dossiersCollection
        .orderBy('dateSoumission', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Dossier.fromFirestore(doc)).toList());
  }
  Future<void> soumettreNouveauDossier(Dossier dossier) async {
    await _dossiersCollection.add(dossier.toFirestore());
  }
  Future<List<Dossier>> recupererDossiersUtilisateur(String userId) async {
    final snapshot = await _dossiersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('dateSoumission', descending: true)
        .get();
    return snapshot.docs.map((doc) => Dossier.fromFirestore(doc)).toList();
  }
  Future<void> updateDossierStatus(String dossierId, String nouveauStatut, {String? motif}) async {
    final Map<String, dynamic> dataToUpdate = {'statut': nouveauStatut, 'dateMiseAJour': Timestamp.now()};
    if (motif != null && motif.isNotEmpty) { dataToUpdate['motifRejet'] = motif; }
    await _dossiersCollection.doc(dossierId).update(dataToUpdate);
  }
  Future<Dossier?> recupererDossierParId(String dossierId) async {
    final docSnapshot = await _dossiersCollection.doc(dossierId).get();
    if (docSnapshot.exists) { return Dossier.fromFirestore(docSnapshot); }
    return null;
  }
  Future<List<Dossier>> recupererDossiersParIds(List<String> ids) async {
    if (ids.isEmpty) { return []; }
    final snapshot = await _dossiersCollection.where(FieldPath.documentId, whereIn: ids).get();
    return snapshot.docs.map((doc) => Dossier.fromFirestore(doc)).toList();
  }

  // --- MÉTHODES LISTINGS ---
  Stream<List<Listing>> getListingsStream() {
    return _listingsCollection
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }
  Stream<List<Listing>> getListingsParStatutsStream(List<String> statuts) {
    return _listingsCollection
        .where('statut', whereIn: statuts)
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }
  Future<bool> creerListingNotifierEtMajDossiers({
    required Listing listing,
    required List<Dossier> dossiers,
    required String nouveauStatutDossier,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        final listingRef = _listingsCollection.doc();
        transaction.set(listingRef, listing.toFirestore());
        for (final dossier in dossiers) {
          final dossierRef = _dossiersCollection.doc(dossier.id!);
          transaction.update(dossierRef, {'statut': nouveauStatutDossier, 'dateMiseAJour': FieldValue.serverTimestamp()});
          final notificationRef = _notificationsCollection.doc();
          final notification = AppNotification(
            userId: dossier.userId,
            titre: "Votre dossier est prêt pour le paiement",
            message: "Bonjour ${dossier.prenomAssure}, votre dossier a été validé. Vous pouvez vous présenter à la caisse pour percevoir vos allocations.",
            dateCreation: DateTime.now(),
          );
          transaction.set(notificationRef, notification.toFirestore());
        }
      });
      return true;
    } catch (e) {
      print("ERREUR LORS DE LA CRÉATION DU LISTING: $e");
      return false;
    }
  }

  // MÉTHODE MANQUANTE AJOUTÉE ICI
  Future<bool> payerDossierDansListing({
    required String listingId,
    required Dossier dossierPaye,
  }) async {
    try {
      await _db.runTransaction((transaction) async {
        final listingRef = _listingsCollection.doc(listingId);
        
        final listingSnapshot = await transaction.get(listingRef);
        if (!listingSnapshot.exists) {
          throw Exception("Listing non trouvé !");
        }
        final listing = Listing.fromFirestore(listingSnapshot as DocumentSnapshot<Map<String, dynamic>>);

        final indexDossier = listing.dossiers.indexWhere((d) => d.dossierId == dossierPaye.id);
        if (indexDossier != -1) {
          listing.dossiers[indexDossier].statutPaiement = 'Payé';
        }

        final tousPayes = listing.dossiers.every((d) => d.statutPaiement == 'Payé');
        listing.statut = tousPayes ? 'Payé' : 'Partiellement Payé';

        transaction.update(listingRef, {'dossiers': listing.dossiers.map((d) => d.toMap()).toList(), 'statut': listing.statut});
        
        final dossierRef = _dossiersCollection.doc(dossierPaye.id!);
        transaction.update(dossierRef, {'statut': 'Payé', 'dateMiseAJour': FieldValue.serverTimestamp()});

        final notificationRef = _notificationsCollection.doc();
        final notification = AppNotification(
          userId: dossierPaye.userId,
          titre: 'Paiement effectué',
          message: 'Bonne nouvelle ! Le paiement de votre allocation a été effectué. Le processus est maintenant terminé.',
          dateCreation: DateTime.now(),
          dossierId: dossierPaye.id!,
        );
        transaction.set(notificationRef, notification.toFirestore());
      });
      return true;
    } catch (e) {
      print("ERREUR LORS DU PAIEMENT DU DOSSIER: $e");
      return false;
    }
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