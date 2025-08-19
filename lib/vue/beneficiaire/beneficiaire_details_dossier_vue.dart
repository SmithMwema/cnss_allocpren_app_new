// lib/vue/beneficiaire/beneficiaire_details_dossier_vue.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controleur/beneficiaire_details_dossier_ctrl.dart';
import '../../modele/dossier.dart';

class BeneficiaireDetailsDossierVue extends GetView<BeneficiaireDetailsDossierCtrl> {
  const BeneficiaireDetailsDossierVue({super.key});

  @override
  Widget build(BuildContext context) {
    // Le contrôleur est initialisé par la route
    Get.lazyPut(() => BeneficiaireDetailsDossierCtrl());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de ma Déclaration"),
        backgroundColor: const Color(0xff1b263b),
      ),
      body: Obx(() {
        if (controller.dossier.value == null) {
          return const Center(child: Text("Aucun dossier sélectionné ou erreur de chargement."));
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
            
            _buildSectionTitle("I. Mes Informations (Assurée)"),
            _buildInfoCard([
              _buildInfoRow("Nom complet:", "${dossier.prenomAssure} ${dossier.nomAssure}"),
              _buildInfoRow("État Civil:", dossier.etatCivilAssure),
              _buildInfoRow("N° Sécurité Sociale:", dossier.numSecuAssure),
              _buildInfoRow("Adresse:", dossier.adresseAssure),
              _buildInfoRow("Email:", dossier.emailAssure),
              _buildInfoRow("Téléphone:", dossier.telAssure),
            ]),

            if (dossier.nomBeneficiaire != null && dossier.nomBeneficiaire!.isNotEmpty) ...[
              _buildSectionTitle("II. Bénéficiaire (si différente)"),
              _buildInfoCard([
                _buildInfoRow("Nom complet:", "${dossier.prenomBeneficiaire ?? ''} ${dossier.nomBeneficiaire ?? ''}"),
                if (dossier.dateNaissanceBeneficiaire != null)
                  _buildInfoRow("Date de Naissance:", DateFormat('dd/MM/yyyy', 'fr_FR').format(dossier.dateNaissanceBeneficiaire!)),
              ]),
            ],

            _buildSectionTitle("III. Informations Médicales"),
            _buildInfoCard([
              _buildInfoRow("Date prévue d'accouchement:", DateFormat('dd/MM/yyyy', 'fr_FR').format(dossier.datePrevueAccouchement)),
              _buildInfoRow("Certificat médical:", dossier.nomFichierMedical),
            ]),
          ],
        );
      }),
    );
  }
  
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
        case 'Soumis': valueColor = Colors.blue.shade700; break;
        case 'Rejeté': valueColor = Colors.red.shade700; break;
        case 'Traité par Agent': valueColor = Colors.purple.shade700; break;
        case 'Validé par Directeur': valueColor = Colors.orange.shade700; break;
        case 'Payé': valueColor = Colors.green.shade700; break;
        default: valueColor = Colors.grey.shade600;
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
}