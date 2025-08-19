// lib/vue/caissier/caissier_dashboard_vue.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controleur/caissier_dashboard_ctrl.dart';
import '../../modele/listing.dart';

class CaissierDashboardVue extends StatelessWidget {
  const CaissierDashboardVue({super.key});

  @override
  Widget build(BuildContext context) {
    final CaissierDashboardCtrl ctrl = Get.put(CaissierDashboardCtrl());

    return Scaffold(
      drawer: Obx(() => _SideBarCaissier(
        nom: ctrl.nomUtilisateur.value,
        email: ctrl.emailUtilisateur.value,
        onDeconnexion: ctrl.seDeconnecter,
      )),
      appBar: AppBar(
        title: const Text("Espace Caissier"),
        backgroundColor: const Color(0xff0d1b2a),
        actions: [
          Obx(() => Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                "${ctrl.listeListings.length} Listing(s)",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ))
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.listeListings.isEmpty) {
          return const Center(
            child: Text("Aucun listing de paiement en attente."),
          );
        }
        return RefreshIndicator(
          onRefresh: ctrl.chargerDonnees,
          child: ListView.builder(
            itemCount: ctrl.listeListings.length,
            itemBuilder: (context, index) {
              final listing = ctrl.listeListings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.article_outlined, color: Colors.blue, size: 40),
                  title: Text("Listing N° ${listing.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(
                    "Créé le: ${DateFormat('dd/MM/yyyy').format(listing.dateCreation)}\n"
                    "${listing.dossierIds.length} dossiers - Statut: ${listing.statut}"
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => ctrl.voirDetailsListing(listing),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// --- CLASSE SIDEBAR COMPLÈTE ET CORRIGÉE ---
class _SideBarCaissier extends StatelessWidget {
  final String nom;
  final String email;
  final VoidCallback onDeconnexion;

  const _SideBarCaissier({
    required this.nom,
    required this.email,
    required this.onDeconnexion,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xff1b263b),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(nom, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(email),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Color(0xff00a99d),
                child: Icon(Icons.account_balance_wallet_outlined, size: 40, color: Colors.white),
              ),
              decoration: const BoxDecoration(color: Color(0xff0d1b2a)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: Colors.white70),
              title: const Text('Tableau de bord', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text('Se déconnecter', style: TextStyle(color: Colors.white)),
              onTap: onDeconnexion,
            ),
          ],
        ),
      ),
    );
  }
}