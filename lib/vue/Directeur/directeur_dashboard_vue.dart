import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controleur/directeur_dashboard_ctrl.dart';
import 'widgets/tab_dashboard_directeur.dart';
import 'widgets/tab_dossiers_a_valider.dart';

class DirecteurDashboardVue extends StatelessWidget {
  const DirecteurDashboardVue({super.key});

  @override
  Widget build(BuildContext context) {
    final DirecteurDashboardCtrl ctrl = Get.put(DirecteurDashboardCtrl());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de Bord Directeur"),
        actions: [ IconButton(icon: const Icon(Icons.logout), onPressed: ctrl.seDeconnecter) ],
        bottom: TabBar(
          controller: ctrl.tabController,
          tabs: [
            const Tab(icon: Icon(Icons.dashboard), text: "Vue d'Ensemble"),
            Tab(icon: const Icon(Icons.pending_actions), child: Obx(() => Text("À Valider (${ctrl.dossiersAValider.length})"))),
          ],
        ),
      ),
      body: TabBarView(
        controller: ctrl.tabController,
        children: const [
          TabDashboardDirecteur(),
          TabDossiersAValider(),
        ],
      ),
    );
  }
}