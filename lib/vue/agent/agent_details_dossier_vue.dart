// lib/vue/agent/agent_details_dossier_vue.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:cnss_allocpren_app/controleur/agent_details_dossier_ctrl.dart';
import '../../modele/dossier.dart';

class AgentDetailsDossierVue extends GetView<AgentDetailsDossierCtrl> {
  const AgentDetailsDossierVue({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.dossier.value == null 
            ? "Détails du Dossier" 
            : "Dossier de ${controller.dossier.value!.prenomAssure}"
        )),
        backgroundColor: const Color(0xff1b263b),
      ),
      body: Obx(() {
        if (controller.dossier.value == null) {
          return const Center(child: Text("Aucun dossier sélectionné."));
        }
        
        final dossier = controller.dossier.value!;
        
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle("Informations Générales"),
            _buildInfoCard([
              _buildInfoRow("Statut Actuel:", dossier.statut, statut: dossier.statut),
              _buildInfoRow("Date de soumission:", DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(dossier.dateSoumission)),
              if (dossier.motifRejet != null && dossier.motifRejet!.isNotEmpty)
                _buildInfoRow("Motif du Rejet:", dossier.motifRejet!, statut: 'Rejeté'),
            ]),
            
            _buildSectionTitle("I. Informations sur l'Assurée"),
            _buildInfoCard([
              _buildInfoRow("Nom complet:", "${dossier.prenomAssure} ${dossier.nomAssure}"),
              _buildInfoRow("État Civil:", dossier.etatCivilAssure),
              _buildInfoRow("N° Sécurité Sociale:", dossier.numSecuAssure),
              _buildInfoRow("Adresse:", dossier.adresseAssure),
              _buildInfoRow("Email:", dossier.emailAssure),
              _buildInfoRow("Téléphone:", dossier.telAssure),
            ]),

            _buildSectionTitle("II. Informations sur l'Employeur"),
            _buildInfoCard([
              _buildInfoRow("Nom:", dossier.employeurAssure),
              _buildInfoRow("N° d'Affiliation:", dossier.numAffiliationEmployeur),
              _buildInfoRow("Adresse:", dossier.adresseEmployeur),
            ]),

            if (dossier.nomBeneficiaire != null && dossier.nomBeneficiaire!.isNotEmpty) ...[
              _buildSectionTitle("III. Bénéficiaire (si différente)"),
              _buildInfoCard([
                // --- CORRECTION APPLIQUÉE ICI ---
                // On utilise 'nomBeneficiaire' et 'prenomBeneficiaire' qui existent dans le modèle.
                _buildInfoRow("Nom complet:", "${dossier.prenomBeneficiaire ?? ''} ${dossier.nomBeneficiaire ?? ''}"),
                if (dossier.dateNaissanceBeneficiaire != null)
                  _buildInfoRow("Date de Naissance:", DateFormat('dd/MM/yyyy', 'fr_FR').format(dossier.dateNaissanceBeneficiaire!)),
              ]),
            ],

            _buildSectionTitle("IV. Informations Médicales"),
            _buildInfoCard([
              _buildInfoRow("Date prévue d'accouchement:", DateFormat('dd/MM/yyyy', 'fr_FR').format(dossier.datePrevueAccouchement)),
              _buildPieceJointeTile(dossier, context),
            ]),

            const SizedBox(height: 80),
          ],
        );
      }),
      bottomSheet: _buildActionBar(context, controller),
    );
  }
  
  // ... (Le reste du fichier est identique et correct) ...
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff1b263b))),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {String? statut}) {
    Color valueColor = Colors.black87;
    FontWeight fontWeight = FontWeight.normal;

    if (statut != null) {
      fontWeight = FontWeight.bold;
      switch (statut) {
        case 'Soumis': valueColor = Colors.orange.shade700; break;
        case 'Rejeté': valueColor = Colors.red.shade700; break;
        case 'Traité par Agent': valueColor = Colors.purple.shade700; break;
        case 'Validé par Directeur': valueColor = Colors.blue.shade700; break;
        case 'Payé': valueColor = Colors.green.shade700; break;
      }
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black54)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15, color: valueColor, fontWeight: fontWeight), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildPieceJointeTile(Dossier dossier, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text("Voir le Certificat Médical"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            Get.defaultDialog(
              title: "Simulation d'Ouverture",
              titleStyle: const TextStyle(fontWeight: FontWeight.bold),
              middleText: "Affichage du document :\n'${dossier.nomFichierMedical}'\n\nLe document semble conforme.",
              textConfirm: "Fermer",
              confirmTextColor: Colors.white,
              buttonColor: Theme.of(context).primaryColor,
              onConfirm: () => Get.back(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, AgentDetailsDossierCtrl ctrl) {
    if (ctrl.dossier.value?.statut != 'Soumis') {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26, offset: Offset(0, -2))],
      ),
      child: Obx(() => Row(
        children: [
          Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.close), label: const Text("Rejeter"), onPressed: ctrl.isProcessing.value ? null : () => _afficherDialogueRejet(context, ctrl), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white))),
          const SizedBox(width: 16),
          Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.check), label: const Text("Transférer"), onPressed: ctrl.isProcessing.value ? null : ctrl.approuverDossier, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
        ],
      )),
    );
  }

  void _afficherDialogueRejet(BuildContext context, AgentDetailsDossierCtrl ctrl) {
    Get.defaultDialog(
      title: "Motif du Rejet",
      content: Form(key: ctrl.rejetFormKey, child: TextFormField(controller: ctrl.rejetMotifController, decoration: const InputDecoration(hintText: "Expliquez le motif..."), maxLines: 3, validator: (value) => (value == null || value.isEmpty) ? 'Le motif est obligatoire.' : null)),
      textCancel: "Annuler",
      textConfirm: "Confirmer Rejet",
      buttonColor: Colors.red,
      confirmTextColor: Colors.white,
      onConfirm: ctrl.rejeterDossier,
    );
  }
}