// lib/vue/directeur/widgets/TabDossiersAValider.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cnss_allocpren_app/controleur/directeur_dashboard_ctrl.dart';
import 'package:cnss_allocpren_app/modele/dossier.dart';

class TabDossiersAValider extends StatelessWidget {
  const TabDossiersAValider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DirecteurDashboardCtrl ctrl = Get.find<DirecteurDashboardCtrl>();

    return Obx(() {
      if (ctrl.dossiersAValider.isEmpty) {
        return const Center(
          child: Text("Aucun dossier en attente de validation."),
        );
      }
      
      return ListView.builder(
        itemCount: ctrl.dossiersAValider.length,
        itemBuilder: (context, index) {
          final dossier = ctrl.dossiersAValider[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.hourglass_top_rounded, color: Colors.purple),
              title: Text("${dossier.prenomAssure} ${dossier.nomAssure}"),
              
              // --- CORRECTION APPLIQUÉE ICI ---
              // On supprime l'appel ".toDate()" car "dateMiseAJour" est déjà un DateTime.
              // On ajoute une vérification pour s'assurer que la date n'est pas nulle avant de la formater.
              subtitle: Text(dossier.dateMiseAJour != null
                  ? "Traité par l'agent le : ${DateFormat('dd/MM/yyyy').format(dossier.dateMiseAJour!)}"
                  : "Date de mise à jour non disponible"),

              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _afficherDialogueActions(context, ctrl, dossier);
              },
            ),
          );
        },
      );
    });
  }

  // ... (Le reste du fichier est identique et ne nécessite aucune modification) ...

  void _afficherDialogueActions(BuildContext context, DirecteurDashboardCtrl ctrl, Dossier dossier) {
    Get.defaultDialog(
      title: "Action Requise",
      middleText: "Que souhaitez-vous faire avec le dossier de ${dossier.nomAssure} ?",
      textConfirm: "Valider",
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        Get.back();
        ctrl.validerDossier(dossier);
      },
      textCancel: "Rejeter",
      cancelTextColor: Colors.red,
      onCancel: () {
        Get.back();
        _afficherDialogueRejet(context, ctrl, dossier);
      },
    );
  }

  void _afficherDialogueRejet(BuildContext context, DirecteurDashboardCtrl ctrl, Dossier dossier) {
    final motifController = TextEditingController();
    Get.defaultDialog(
      title: "Motif du Rejet",
      content: TextFormField(
        controller: motifController,
        decoration: const InputDecoration(
          labelText: 'Motif obligatoire',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      textConfirm: "Confirmer le Rejet",
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (motifController.text.isNotEmpty) {
          Get.back();
          ctrl.rejeterDossier(dossier, motifController.text);
        } else {
          Get.snackbar("Champ Requis", "Veuillez saisir un motif pour le rejet.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white);
        }
      },
      textCancel: "Annuler",
    );
  }
}