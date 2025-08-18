import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controleur/directeur_dashboard_ctrl.dart';

class TabDashboardDirecteur extends StatelessWidget {
  const TabDashboardDirecteur({super.key});

  @override
  Widget build(BuildContext context) {
    final DirecteurDashboardCtrl ctrl = Get.find<DirecteurDashboardCtrl>();

    return RefreshIndicator(
      onRefresh: ctrl.chargerDonnees,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Statistiques Générales", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildKpiGrid(ctrl),
            const SizedBox(height: 24),
            Text("Supervision de Tous les Dossiers", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                if(ctrl.isLoading.value && ctrl.tousLesDossiers.isEmpty) return const Center(child: CircularProgressIndicator());
                if(ctrl.tousLesDossiers.isEmpty) return const Center(child: Text("Aucun dossier dans le système."));
                
                return DataTable(
                  columns: const [DataColumn(label: Text('ID')), DataColumn(label: Text('Nom')), DataColumn(label: Text('Statut'))],
                  rows: ctrl.tousLesDossiers.map((dossier) => DataRow(cells: [
                    DataCell(Text(dossier.id.toString())),
                    DataCell(Text(dossier.nomAssure)),
                    DataCell(Chip(
                      label: Text(dossier.statut, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: ctrl.getColorForStatus(dossier.statut),
                    )),
                  ])).toList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
  
  // --- FONCTION COMPLÉTÉE ---
  Widget _buildKpiGrid(DirecteurDashboardCtrl ctrl) {
    return Obx(() => GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2 / 1.5,
      children: [
        _buildKpiCard("Total des Dossiers", ctrl.totalDossiers.value.toString(), Icons.folder_copy, Colors.blue),
        _buildKpiCard("Dossiers Payés", ctrl.dossiersPayes.value.toString(), Icons.check_circle, Colors.green),
        _buildKpiCard("Dossiers en Attente", ctrl.dossiersEnAttente.value.toString(), Icons.pending_actions, Colors.orange),
        _buildKpiCard("Dossiers Rejetés", ctrl.dossiersRejetes.value.toString(), Icons.cancel, Colors.red),
      ],
    ));
  }

  // --- FONCTION COMPLÉTÉE ---
  Widget _buildKpiCard(String titre, String valeur, IconData icone, Color couleur) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icone, size: 32, color: couleur),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(valeur, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
                Text(titre, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}