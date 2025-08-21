// lib/vue/caissier/caissier_listing_details_vue.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controleur/caissier_listing_details_ctrl.dart';
import '../../modele/dossier.dart';
import '../../modele/listing.dart';

class CaissierListingDetailsVue extends GetView<CaissierListingDetailsCtrl> {
  const CaissierListingDetailsVue({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => CaissierListingDetailsCtrl());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.listing.value == null
            ? "Détails du Listing"
            : "Listing du ${DateFormat('dd/MM/yy').format(controller.listing.value!.dateCreation)}")),
        backgroundColor: const Color(0xff0d1b2a),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.dossiersDuListing.isEmpty) {
          return const Center(child: Text("Aucun dossier trouvé pour ce listing."));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: _buildDataTable(),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildDataTable() {
    return DataTable(
      columnSpacing: 20.0,
      columns: const [
        DataColumn(label: Text('N° Sécu', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Nom Complet', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Statut Paiement', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: controller.dossiersDuListing.map((dossier) {
        final paiementInfo = controller.listing.value!.dossiers.firstWhere(
          (p) => p.dossierId == dossier.id,
          orElse: () => DossierPaiement(dossierId: dossier.id!),
        );
        final estPaye = paiementInfo.statutPaiement == 'Payé';

        return DataRow(
          color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) => estPaye ? Colors.green.withOpacity(0.1) : null,
          ),
          cells: [
            DataCell(Text(dossier.numSecuAssure)),
            DataCell(Text("${dossier.prenomAssure} ${dossier.nomAssure}")),
            DataCell(
              Text(
                estPaye ? "Payé" : "En attente",
                style: TextStyle(color: estPaye ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
              )
            ),
            DataCell(
              Obx(() {
                if (controller.processingPaymentId.value == dossier.id) {
                  return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator());
                }
                if (estPaye) {
                  return TextButton(
                    onPressed: () { /* TODO: Imprimer la preuve de paiement */ },
                    child: const Text("Preuve"),
                  );
                }
                return ElevatedButton(
                  onPressed: () => controller.confirmerPaiement(dossier),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Payer"),
                );
              }),
            ),
          ],
        );
      }).toList(),
    );
  }
}