// lib/vue/caissier/caissier_listing_details_vue.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controleur/caissier_listing_details_ctrl.dart';
import '../../modele/dossier.dart';

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
        if (controller.listing.value == null) {
          return const Center(child: Text("Impossible de charger les détails du listing."));
        }

        return ListView.builder(
          itemCount: controller.dossiersDuListing.length,
          itemBuilder: (context, index) {
            final dossier = controller.dossiersDuListing[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: dossier.statut == 'Payé' ? Colors.green.shade50 : null,
              child: ListTile(
                leading: Icon(
                  dossier.statut == 'Payé' ? Icons.check_circle : Icons.person_outline,
                  color: dossier.statut == 'Payé' ? Colors.green : Colors.blue,
                  size: 40,
                ),
                title: Text("${dossier.prenomAssure} ${dossier.nomAssure}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("N° Sécu: ${dossier.numSecuAssure}"),
                trailing: Obx(() {
                  // Le bouton change en fonction du statut du dossier
                  if (controller.processingPaymentId.value == dossier.id) {
                    return const CircularProgressIndicator();
                  }
                  if (dossier.statut == 'Payé') {
                    return ElevatedButton.icon(
                      onPressed: () { /* TODO: Imprimer la preuve de paiement */ },
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: const Text("Preuve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                      ),
                    );
                  }
                  return ElevatedButton(
                    onPressed: () => controller.confirmerPaiement(dossier),
                    child: const Text("Payer"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  );
                }),
              ),
            );
          },
        );
      }),
    );
  }
}