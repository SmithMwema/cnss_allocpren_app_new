// lib/vue/agent/agent_dashboard_vue.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controleur/agent_dashboard_ctrl.dart';
import '../../modele/dossier.dart';

class AgentDashboardVue extends GetView<AgentDashboardCtrl> {
  const AgentDashboardVue({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialise le contrôleur (nécessaire si non fait par la route)
    Get.lazyPut(() => AgentDashboardCtrl());

    final List<Widget> pages = [
      _buildTraitementPage(controller),
      _buildHistoriquePage(controller),
    ];

    return Scaffold(
      drawer: _buildAgentSideBar(controller),
      appBar: AppBar(
        // La barre de titre change pour afficher la barre de recherche
        title: Obx(() => controller.isSearching.value
            ? TextField(
                controller: controller.searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher par nom...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text("Espace Agent PF")),
        backgroundColor: const Color(0xff1b263b),
        actions: [
          // Bouton pour activer/désactiver la recherche
          Obx(() => controller.isSearching.value
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: controller.stopSearch,
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: controller.startSearch,
                ))
        ],
      ),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: controller.changePage,
            destinations: [
              NavigationDestination(
                icon: Badge(
                  label: Text(controller.dossiersATraiter.length.toString()),
                  isLabelVisible: controller.dossiersATraiter.isNotEmpty,
                  child: const Icon(Icons.hourglass_top_outlined),
                ),
                label: 'À Traiter',
              ),
              NavigationDestination(
                icon: Badge(
                  label: Text(controller.dossiersTraites.length.toString()),
                  isLabelVisible: controller.dossiersTraites.isNotEmpty,
                  child: const Icon(Icons.history_outlined),
                ),
                label: 'Historique',
              ),
            ],
          )),
      body: Obx(() {
        if (controller.isLoading.value && controller.dossiersATraiter.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return pages[controller.selectedIndex.value];
      }),
    );
  }

  Widget _buildTraitementPage(AgentDashboardCtrl ctrl) {
    return Obx(() {
      // ON UTILISE LA LISTE FILTRÉE
      final dossiers = ctrl.filteredDossiersATraiter;
      if (dossiers.isEmpty) {
        return _buildEmptyState("Aucun dossier à traiter", Icons.inbox_outlined);
      }
      return ListView.builder(
        itemCount: dossiers.length,
        itemBuilder: (context, index) {
          final Dossier dossier = dossiers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.orange, size: 40),
              title: Text("${dossier.prenomAssure} ${dossier.nomAssure}", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Soumis le: ${DateFormat('dd/MM/yyyy').format(dossier.dateSoumission)}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => ctrl.voirDetailsDossier(dossier),
            ),
          );
        },
      );
    });
  }

  Widget _buildHistoriquePage(AgentDashboardCtrl ctrl) {
    return Obx(() {
      // ON UTILISE LA LISTE FILTRÉE
      final dossiers = ctrl.filteredDossiersTraites;
      if (dossiers.isEmpty) {
        return _buildEmptyState("Aucun dossier dans l'historique", Icons.history);
      }
      return ListView.builder(
        itemCount: dossiers.length,
        itemBuilder: (context, index) {
          final Dossier dossier = dossiers[index];
          String dateTraiteeText = "Date de traitement non disponible";
          if (dossier.dateMiseAJour != null) {
            dateTraiteeText = "Traité le: ${DateFormat('dd/MM/yyyy').format(dossier.dateMiseAJour!)}";
          }
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Icon(
                dossier.statut == 'Rejeté' ? Icons.folder_off_outlined : Icons.folder_shared_outlined,
                color: dossier.statut == 'Rejeté' ? Colors.red : Colors.green.shade600,
                size: 40,
              ),
              title: Text("${dossier.prenomAssure} ${dossier.nomAssure}"),
              subtitle: Text("Statut: ${dossier.statut}\n$dateTraiteeText"),
              isThreeLine: true,
              onTap: () => ctrl.voirDetailsDossier(dossier),
            ),
          );
        },
      );
    });
  }

  Widget _buildAgentSideBar(AgentDashboardCtrl ctrl) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Agent de Prestations"),
            accountEmail: Text(ctrl.emailUtilisateur.value),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Color(0xff1b263b)),
            ),
            decoration: const BoxDecoration(color: Color(0xff1b263b)),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () {
              Get.back();
              Get.toNamed('/notifications');
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Changer de Thème'),
            onTap: () {
              Get.back();
              _afficherDialogueTheme(Get.context!);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () => ctrl.seDeconnecter(),
          ),
        ],
      ),
    );
  }

  void _afficherDialogueTheme(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choisir un thème"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Thème Clair"),
                onTap: () { Get.changeThemeMode(ThemeMode.light); Get.back(); },
              ),
              ListTile(
                title: const Text("Thème Sombre"),
                onTap: () { Get.changeThemeMode(ThemeMode.dark); Get.back(); },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }
}