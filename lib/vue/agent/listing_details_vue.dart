// lib/vue/agent/listing_details_vue.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controleur/listing_details_ctrl.dart';
import '../../modele/dossier.dart';

class ListingDetailsVue extends GetView<ListingDetailsCtrl> {
  const ListingDetailsVue({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ListingDetailsCtrl());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.listing.value == null
            ? "Détails du Listing"
            : "Listing du ${DateFormat('dd/MM/yy').format(controller.listing.value!.dateCreation)}")),
        backgroundColor: const Color(0xff1b263b),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: controller.exporterEnCsv,
            tooltip: "Exporter en CSV (Excel)",
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: controller.imprimerListing,
            tooltip: "Imprimer le Listing",
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.listing.value == null) {
          return const Center(child: Text("Impossible de charger les détails du listing."));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Détails du Listing",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildInfoRow("Référence:", controller.listing.value!.id!),
              _buildInfoRow("Statut:", controller.listing.value!.statut),
              _buildInfoRow("Nombre de dossiers:", controller.dossiersDuListing.length.toString()),
              const SizedBox(height: 24),
              Text(
                "Bénéficiaires Incluses",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _buildDataTable(controller.dossiersDuListing),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Dossier> dossiers) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('N°')),
        DataColumn(label: Text('N° Sécu')),
        DataColumn(label: Text('Nom Complet')),
      ],
      rows: dossiers.asMap().entries.map(
        (entry) {
          int index = entry.key + 1;
          Dossier dossier = entry.value;
          return DataRow(cells: [
            DataCell(Text(index.toString())),
            DataCell(Text(dossier.numSecuAssure)),
            DataCell(Text("${dossier.prenomAssure} ${dossier.nomAssure}")),
          ]);
        },
      ).toList(),
    );
  }
}