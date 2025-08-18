// lib/vue/notification_vue.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:cnss_allocpren_app/controleur/notification_ctrl.dart';
import 'package:cnss_allocpren_app/modele/notification.dart'; // Ajout de l'import pour la clarté

class NotificationVue extends StatelessWidget {
  const NotificationVue({super.key});

  @override
  Widget build(BuildContext context) {
    // Il est préférable d'utiliser Get.find() si un Binding est utilisé, sinon Get.put() est correct.
    final NotificationCtrl ctrl = Get.put(NotificationCtrl());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Notifications"),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.notifications.isEmpty) {
          return const Center(
            child: Text(
              "Vous n'avez aucune notification.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          itemCount: ctrl.notifications.length,
          itemBuilder: (context, index) {
            final AppNotification notif = ctrl.notifications[index];
            final bool isLue = notif.estLue;

            // Amélioration : Utiliser un Card pour un meilleur rendu visuel
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: isLue ? Colors.white : Colors.blue[50], // Surligner les notifications non lues
              child: ListTile(
                leading: Icon(
                  isLue ? Icons.mark_email_read_outlined : Icons.mark_email_unread,
                  color: isLue ? Colors.grey : Theme.of(context).primaryColor,
                ),
                title: Text(
                  notif.titre,
                  style: TextStyle(fontWeight: isLue ? FontWeight.normal : FontWeight.bold),
                ),
                subtitle: Text(notif.message),
                
                // --- CORRECTION APPLIQUÉE ICI ---
                // On utilise 'notif.dateCreation' et on retire '.toDate()'
                trailing: Text(DateFormat('dd/MM/yy').format(notif.dateCreation)),
                
                onTap: () {
                  // On ne marque comme lue que si elle ne l'est pas déjà
                  if (!isLue) {
                    ctrl.marquerCommeLue(notif);
                  }
                  // On pourrait aussi naviguer vers les détails du dossier ici
                  // if (notif.dossierId != null) { ... }
                },
              ),
            );
          },
        );
      }),
    );
  }
}