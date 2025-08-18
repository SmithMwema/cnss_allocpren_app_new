// lib/vue/declaration_vue.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// IMPORTANT : Assurez-vous que ce chemin est correct (sans accent)
import '../controleur/declaration_ctrl.dart';

class DeclarationVue extends GetView<DeclarationCtrl> {
  const DeclarationVue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Déclaration'),
      ),
      body: Obx(() => Stepper(
        type: StepperType.vertical,
        currentStep: controller.currentStep.value,
        onStepContinue: controller.onStepContinue,
        onStepCancel: controller.onStepCancel,
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(controller.currentStep.value == 2 ? 'SOUMETTRE' : 'CONTINUER'),
                ),
                if (controller.currentStep.value > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('RETOUR'),
                  ),
              ],
            ),
          );
        },
        steps: [
          // --- ÉTAPE 1: INFORMATIONS DE L'ASSURÉE ---
          Step(
            title: const Text('Informations de l\'assurée'),
            content: Form(
              key: controller.formKeyEtape1,
              child: Column(
                children: [
                  _buildTextFormField(controller.nomAssureCtrl, 'Nom'),
                  _buildTextFormField(controller.prenomAssureCtrl, 'Prénom'),
                  _buildTextFormField(controller.etatCivilAssureCtrl, 'État Civil'),
                  _buildTextFormField(controller.numSecuAssureCtrl, 'N° de Sécurité Sociale'),
                  _buildTextFormField(controller.adresseAssureCtrl, 'Adresse'),
                  _buildTextFormField(controller.emailAssureCtrl, 'Email', keyboardType: TextInputType.emailAddress),
                  _buildTextFormField(controller.telAssureCtrl, 'Téléphone', keyboardType: TextInputType.phone),
                  _buildTextFormField(controller.employeurAssureCtrl, 'Employeur'),
                  _buildTextFormField(controller.numAffiliationEmployeurCtrl, 'N° Affiliation Employeur'),
                  _buildTextFormField(controller.adresseEmployeurCtrl, 'Adresse Employeur'),
                ],
              ),
            ),
            isActive: controller.currentStep.value >= 0,
            state: controller.currentStep.value > 0 ? StepState.complete : StepState.indexed,
          ),

          // --- ÉTAPE 2: INFORMATIONS DE LA BÉNÉFICIAIRE ---
          Step(
            title: const Text('Bénéficiaire (si différente)'),
            content: Form(
              key: controller.formKeyEtape2,
              child: Column(
                children: [
                  _buildTextFormField(controller.nomBeneficiaireCtrl, 'Nom', isRequired: false),
                  // CORRECTION : Utilise le bon contrôleur et le bon libellé.
                  _buildTextFormField(controller.prenomBeneficiaireCtrl, 'Prénom', isRequired: false),
                  
                  TextFormField(
                    controller: controller.dateNaissanceBeneficiaireCtrl,
                    decoration: const InputDecoration(labelText: 'Date de naissance', border: OutlineInputBorder()),
                    readOnly: true,
                    onTap: () => controller.choisirDateNaissanceBeneficiaire(context),
                  ),
                ],
              ),
            ),
            isActive: controller.currentStep.value >= 1,
            state: controller.currentStep.value > 1 ? StepState.complete : StepState.indexed,
          ),

          // --- ÉTAPE 3: INFORMATIONS MÉDICALES ET PIÈCE JOINTE ---
          Step(
            title: const Text('Informations Médicales'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller.datePrevueAccouchementCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Date prévue d\'accouchement *',
                    border: OutlineInputBorder()
                  ),
                  readOnly: true,
                  onTap: () => controller.choisirDatePrevueAccouchement(context),
                  validator: (value) => value!.isEmpty ? 'Date requise' : null,
                ),
                const SizedBox(height: 24),
                const Text("Joindre le certificat médical *", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: controller.selectionnerFichier,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Choisir un fichier'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(() => Text(
                        controller.nomFichierSelectionne.value,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ),
                  ],
                ),
              ],
            ),
            isActive: controller.currentStep.value >= 2,
          ),
        ],
      )),
    );
  }

  Widget _buildTextFormField(TextEditingController ctrl, String label, {bool isRequired = true, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: isRequired
            ? (value) => value == null || value.isEmpty ? 'Ce champ est requis' : null
            : null,
      ),
    );
  }
}