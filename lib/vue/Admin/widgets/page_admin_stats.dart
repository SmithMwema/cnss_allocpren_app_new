import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controleur/admin_dashboard_ctrl.dart';

class PageAdminStats extends StatelessWidget {
  const PageAdminStats({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminDashboardCtrl ctrl = Get.find<AdminDashboardCtrl>();
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: ctrl.chargerToutesLesDonnees,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Statistiques des Utilisateurs", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              _buildKpiGrid(ctrl),
              
              const SizedBox(height: 24),
              Text("Répartition des Rôles du Personnel", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 300,
                child: Obx(() {
                  if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
                  // On utilise la bonne variable "userStatsData"
                  if (ctrl.userStatsData.isEmpty) return const Center(child: Text("Aucun utilisateur du personnel à analyser."));
                  
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: ctrl.userStatsData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [BarChartRodData(toY: data.nombre.toDouble(), color: data.couleur, width: 25)],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                          return SideTitleWidget(axisSide: meta.axisSide, child: Text(ctrl.userStatsData[value.toInt()].role, style: const TextStyle(fontSize: 10)));
                        }, reservedSize: 20)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildKpiGrid(AdminDashboardCtrl ctrl) {
    return Obx(() => GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5 / 1,
      children: [
        _buildKpiCard("Utilisateurs Total", ctrl.totalUtilisateurs.value.toString(), Icons.people, Colors.blue),
        _buildKpiCard("Bénéficiaires", ctrl.totalBeneficiaires.value.toString(), Icons.woman, Colors.pink),
      ],
    ));
  }

  Widget _buildKpiCard(String titre, String valeur, IconData icone, Color couleur) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icone, size: 32, color: couleur),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(valeur, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(titre, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}