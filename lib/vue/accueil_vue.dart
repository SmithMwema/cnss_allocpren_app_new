// lib/vue/accueil_vue.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controleur/accueil_ctrl.dart';
import 'composants/side_bar_personnel.dart';

class AccueilVue extends GetView<AccueilCtrl> {
  const AccueilVue({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Obx(() => SideBarPersonnel(
        nom: controller.nomUtilisateur.value,
        email: controller.emailUtilisateur.value,
        onDeconnexion: controller.seDeconnecter,
        itemsSupplementaires: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: Colors.white70),
            title: const Text('Mes Notifications', style: TextStyle(color: Colors.white)),
            onTap: () {
              Get.back();
              controller.allerVersNotifications();
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: Colors.white70),
            title: const Text('Changer de Thème', style: TextStyle(color: Colors.white)),
            onTap: () {
              Get.back();
              _afficherDialogueTheme(context);
            },
          ),
        ],
      )),
      appBar: AppBar(
        title: const Text("Mon Espace"),
        backgroundColor: const Color(0xff1b263b),
        actions: [
          Obx(() => Badge(
            isLabelVisible: controller.aDesNotificationsNonLues.value,
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: controller.allerVersNotifications,
              tooltip: "Notifications",
            ),
          )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.chargerDonneesAccueil,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                "Bonjour, ${controller.nomUtilisateur.value}",
                style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
              )),
              const SizedBox(height: 30),
              _buildActionButton(
                icon: Icons.add_circle_outline,
                titre: "Nouvelle Déclaration",
                sousTitre: "Commencer une nouvelle procédure",
                onTap: controller.allerVersDeclaration,
              ),
              const SizedBox(height: 30),
              Text("Historique de mes Déclarations", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
              const Divider(thickness: 1.5),
              const SizedBox(height: 10),
              Obx(() {
                if (controller.isLoading.value && controller.listeDossiers.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                }
                if (controller.listeDossiers.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Text("Vous n'avez aucune déclaration pour le moment."),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.listeDossiers.length,
                  itemBuilder: (context, index) {
                    final dossier = controller.listeDossiers[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Icon(_getIconForStatus(dossier.statut), color: _getColorForStatus(dossier.statut), size: 40),
                        title: Text("Dossier soumis le ${DateFormat('dd/MM/yy', 'fr_FR').format(dossier.dateSoumission)}"),
                        subtitle: Text("Statut: ${dossier.statut}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        
                        // --- ACTION DE CLIC AJOUTÉE ICI ---
                        onTap: () {
                          // On appelle la méthode du contrôleur pour gérer la navigation.
                          controller.allerVersDetailsDossier(dossier);
                        },
                      ),
                    );
                  },
                );
              })
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForStatus(String statut) {
    switch (statut) {
      case 'Soumis': return Colors.blue.shade700;
      case 'Traité par Agent': return Colors.purple.shade700;
      case 'Validé par Directeur': return Colors.orange.shade700;
      case 'Payé': return Colors.green.shade700;
      case 'Rejeté': return Colors.red.shade700;
      default: return Colors.grey;
    }
  }

  IconData _getIconForStatus(String statut) {
    switch (statut) {
      case 'Soumis': return Icons.hourglass_top_outlined;
      case 'Traité par Agent': return Icons.admin_panel_settings_outlined;
      case 'Validé par Directeur': return Icons.approval_outlined;
      case 'Payé': return Icons.check_circle_outline;
      case 'Rejeté': return Icons.cancel_outlined;
      default: return Icons.help_outline;
    }
  }

  Widget _buildActionButton({required IconData icon, required String titre, required String sousTitre, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Get.theme.primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(sousTitre, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
  
  void _afficherDialogueTheme(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Text("Choisir un thème", style: Theme.of(context).textTheme.titleLarge),
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
}