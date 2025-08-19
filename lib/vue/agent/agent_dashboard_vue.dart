// lib/vue/agent/agent_dashboard_vue.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controleur/agent_dashboard_ctrl.dart';
import '../../modele/dossier.dart';
import '../../modele/listing.dart';

class AgentDashboardVue extends GetView<AgentDashboardCtrl> {
  const AgentDashboardVue({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildAgentSideBar(context, controller),
      appBar: AppBar(
        title: Obx(() => controller.isSearching.value
            ? TextField(
                controller: controller.searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              )
            : Text(_getAppBarTitle(controller.selectedIndex.value))),
        backgroundColor: const Color(0xff1b263b),
        actions: [
          Obx(() => controller.isSearching.value
              ? IconButton(icon: const Icon(Icons.close), onPressed: controller.stopSearch)
              : IconButton(icon: const Icon(Icons.search), onPressed: controller.startSearch))
        ],
      ),
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: controller.changePage,
            destinations: [
              NavigationDestination(
                icon: Badge(
                  // CORRIGÉ : Pointeur vers la liste source
                  label: Text(controller.dossiersATraiter.length.toString()),
                  isLabelVisible: controller.dossiersATraiter.isNotEmpty,
                  child: const Icon(Icons.hourglass_top_outlined),
                ),
                label: 'À Traiter',
              ),
              NavigationDestination(
                icon: Badge(
                  // CORRIGÉ : Pointeur vers la liste source
                  label: Text(controller.dossiersPourListing.length.toString()),
                  isLabelVisible: controller.dossiersPourListing.isNotEmpty,
                  child: const Icon(Icons.playlist_add_outlined),
                ),
                label: 'Listings',
              ),
              NavigationDestination(
                icon: const Icon(Icons.manage_search_outlined),
                label: 'Suivi Dossiers',
              ),
              NavigationDestination(
                icon: Badge(
                  // CORRIGÉ : Pointeur vers la liste source
                  label: Text(controller.historiqueListings.length.toString()),
                  isLabelVisible: controller.historiqueListings.isNotEmpty,
                  child: const Icon(Icons.history_edu_outlined),
                ),
                label: 'Hist. Listings',
              ),
            ],
          )),
      floatingActionButton: Obx(() =>
        (controller.selectedIndex.value == 1 && controller.selectedForListing.isNotEmpty)
          ? FloatingActionButton.extended(
              onPressed: controller.genererListing,
              label: Text("Générer Listing (${controller.selectedForListing.length})"),
              icon: const Icon(Icons.playlist_add_check_outlined),
              backgroundColor: Colors.green.shade700,
            )
          : const SizedBox.shrink()
      ),
      body: Obx(() {
        if (controller.isLoading.value) { return const Center(child: CircularProgressIndicator()); }
        if (controller.isProcessingListing.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Création du listing en cours..."),
              ],
            ),
          );
        }
        return _buildCurrentPage(controller);
      }),
    );
  }

  Widget _buildCurrentPage(AgentDashboardCtrl ctrl) {
    final List<dynamic> items = ctrl.listeFiltreeAffichee;
    switch (ctrl.selectedIndex.value) {
      case 0:
        return _buildDossiersListPage(dossiers: items.cast<Dossier>(), isSelectable: false);
      case 1:
        return _buildDossiersListPage(dossiers: items.cast<Dossier>(), isSelectable: true);
      case 2:
        return _buildDossiersListPage(dossiers: items.cast<Dossier>(), isSelectable: false);
      case 3:
        return _buildHistoriqueListingsPage(listings: items.cast<Listing>());
      default:
        return const Center(child: Text("Page non trouvée."));
    }
  }

  Widget _buildHistoriqueListingsPage({ required List<Listing> listings }) {
    if (listings.isEmpty) {
      return _buildEmptyState("Aucun listing n'a encore été généré", Icons.history_edu_outlined);
    }
    return ListView.builder(
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final Listing listing = listings[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.article_outlined, color: Colors.blueGrey, size: 40),
            title: Text("Listing N° ${listing.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            subtitle: Text(
              "Créé le: ${DateFormat('dd/MM/yyyy').format(listing.dateCreation)}\n"
              "${listing.dossierIds.length} dossiers - Statut: ${listing.statut}"
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => controller.voirDetailsListing(listing),
          ),
        );
      },
    );
  }

  Widget _buildDossiersListPage({ required List<Dossier> dossiers, required bool isSelectable }) {
    String emptyMessage;
    IconData emptyIcon;
    switch(controller.selectedIndex.value) {
      case 0: emptyMessage = "Aucun nouveau dossier à traiter"; emptyIcon = Icons.inbox_outlined; break;
      case 1: emptyMessage = "Aucun dossier validé prêt pour un listing"; emptyIcon = Icons.playlist_add_outlined; break;
      case 2: emptyMessage = "Aucun dossier dans le suivi"; emptyIcon = Icons.manage_search_outlined; break;
      default: emptyMessage = ""; emptyIcon = Icons.error;
    }
    if (dossiers.isEmpty) {
      return _buildEmptyState(
        controller.searchQuery.isNotEmpty ? "Aucun résultat trouvé" : emptyMessage,
        controller.searchQuery.isNotEmpty ? Icons.search_off : emptyIcon,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), 
      itemCount: dossiers.length,
      itemBuilder: (context, index) {
        final Dossier dossier = dossiers[index];
        if (isSelectable) {
          return Obx(() => CheckboxListTile(
            secondary: Icon(_getStatusIcon(dossier.statut), color: _getStatusColor(dossier.statut), size: 40),
            title: Text("${dossier.prenomAssure} ${dossier.nomAssure}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("N° Sécu: ${dossier.numSecuAssure}"),
            value: controller.isSelected(dossier),
            onChanged: (bool? value) => controller.toggleSelection(dossier),
          ));
        }
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: Icon(_getStatusIcon(dossier.statut), color: _getStatusColor(dossier.statut), size: 40),
            title: Text("${dossier.prenomAssure} ${dossier.nomAssure}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("N° Sécu: ${dossier.numSecuAssure}\nStatut: ${dossier.statut}"),
            isThreeLine: true,
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => controller.voirDetailsDossier(dossier),
          ),
        );
      },
    );
  }
  
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0: return 'Dossiers à Traiter';
      case 1: return 'Création de Listings';
      case 2: return 'Suivi des Dossiers';
      case 3: return 'Historique des Listings';
      default: return 'Espace Agent';
    }
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'Soumis': return Colors.orange;
      case 'Traité par Agent': return Colors.purple;
      case 'Validé par Directeur': return Colors.blue;
      case 'Prêt pour paiement': return Colors.teal;
      case 'Payé': return Colors.green;
      case 'Rejeté': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String statut) {
    switch (statut) {
      case 'Soumis': return Icons.folder_open;
      case 'Traité par Agent': return Icons.assignment_ind_outlined;
      case 'Validé par Directeur': return Icons.check_circle_outline;
      case 'Prêt pour paiement': return Icons.playlist_add_check_circle_outlined;
      case 'Payé': return Icons.paid_outlined;
      case 'Rejeté': return Icons.folder_off_outlined;
      default: return Icons.help_outline;
    }
  }
  
  Widget _buildAgentSideBar(BuildContext context, AgentDashboardCtrl ctrl) {
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
            onTap: () { Get.back(); Get.toNamed('/notifications'); },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Changer de Thème'),
            onTap: () {
              Get.back();
              _afficherDialogueTheme(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () {
              Get.back();
              ctrl.seDeconnecter();
            },
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