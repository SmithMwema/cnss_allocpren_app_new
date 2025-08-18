// lib/vue/caissier/caissier_dashboard_vue.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controleur/caissier_dashboard_ctrl.dart';
import '../../modele/dossier.dart'; // Cet import est utilisé à la ligne 56

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
                "${ctrl.listeDossiers.length} Dossier(s) à Payer",
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
        if (ctrl.listeDossiers.isEmpty) {
          return const Center(
            child: Text("Aucun dossier en attente de paiement."),
          );
        }
        return RefreshIndicator(
          onRefresh: ctrl.chargerDossiers,
          child: ListView.builder(
            itemCount: ctrl.listeDossiers.length,
            itemBuilder: (context, index) {
              // LA LIGNE CI-DESSOUS UTILISE LA CLASSE 'Dossier'
              final dossier = ctrl.listeDossiers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.payment, color: Colors.green),
                  title: Text("${dossier.prenomAssure} ${dossier.nomAssure}"),
                  subtitle: Text("ID: ${dossier.id}\nValidé par le directeur"),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => ctrl.confirmerPaiement(dossier),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

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
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
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