// lib/vue/caissier/caissier_dashboard_vue.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controleur/caissier_dashboard_ctrl.dart';
import '../../modele/dossier.dart';

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
        title: Obx(() => Text(ctrl.selectedIndex.value == 0 ? "Dossiers à Payer" : "Historique des Paiements")),
        backgroundColor: const Color(0xff0d1b2a),
      ),
      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: ctrl.selectedIndex.value,
        onDestinationSelected: ctrl.changePage,
        destinations: [
          NavigationDestination(
            icon: Badge(
              label: Text(ctrl.dossiersAPayer.length.toString()),
              isLabelVisible: ctrl.dossiersAPayer.isNotEmpty,
              child: const Icon(Icons.payment_outlined),
            ),
            label: 'À Payer',
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            label: 'Historique',
          ),
        ],
      )),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        // Utilise IndexedStack pour conserver l'état de défilement de chaque page
        return IndexedStack(
          index: ctrl.selectedIndex.value,
          children: [
            _buildAPayerPage(ctrl),
            _buildHistoriquePage(ctrl),
          ],
        );
      }),
    );
  }

  Widget _buildAPayerPage(CaissierDashboardCtrl ctrl) {
    if (ctrl.dossiersAPayer.isEmpty) {
      return const Center(child: Text("Aucun dossier en attente de paiement."));
    }
    return RefreshIndicator(
      onRefresh: ctrl.chargerDonnees,
      child: ListView.builder(
        itemCount: ctrl.dossiersAPayer.length,
        itemBuilder: (context, index) {
          final dossier = ctrl.dossiersAPayer[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.blue, size: 40),
              title: Text("${dossier.prenomAssure} ${dossier.nomAssure}", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("N° Sécu: ${dossier.numSecuAssure}"),
              trailing: ElevatedButton(
                onPressed: () => ctrl.confirmerPaiement(dossier),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Payer"),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoriquePage(CaissierDashboardCtrl ctrl) {
    if (ctrl.historiquePaiements.isEmpty) {
      return const Center(child: Text("Aucun paiement dans l'historique."));
    }
    return ListView.builder(
      itemCount: ctrl.historiquePaiements.length,
      itemBuilder: (context, index) {
        final dossier = ctrl.historiquePaiements[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
            title: Text("${dossier.prenomAssure} ${dossier.nomAssure}"),
            subtitle: Text(
              "N° Sécu: ${dossier.numSecuAssure}\n"
              "Payé le: ${dossier.dateMiseAJour != null ? DateFormat('dd/MM/yyyy').format(dossier.dateMiseAJour!) : 'N/A'}"
            ),
            isThreeLine: true,
          ),
        );
      },
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