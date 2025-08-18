import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controleur/admin_dashboard_ctrl.dart';
import '../../../routes/app_pages.dart'; // IMPORTANT : On importe les routes

class PageCreerUtilisateur extends StatelessWidget {
  const PageCreerUtilisateur({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminDashboardCtrl ctrl = Get.find<AdminDashboardCtrl>();

    return Scaffold(
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.listeUtilisateurs.isEmpty) {
          return const Center(child: Text("Aucun utilisateur trouvé dans le système."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: ctrl.listeUtilisateurs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Utilisateurs du Système (${ctrl.listeUtilisateurs.length})",
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              );
            }
            final utilisateur = ctrl.listeUtilisateurs[index - 1];
            return _buildUserCard(
              utilisateur.nom,
              utilisateur.email,
              utilisateur.role,
              _getColorForRole(utilisateur.role),
            );
          },
        );
      }),
      
      // --- CORRECTION DU BOUTON FLOTTANT ---
      floatingActionButton: FloatingActionButton.extended(
        // Il navigue maintenant vers la page de formulaire
        onPressed: () => Get.toNamed(AppPages.adminAddUser),
        label: const Text("Ajouter un utilisateur"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Color _getColorForRole(String role) {
    switch (role) {
      case 'agent': return Colors.purple;
      case 'directeur': return Colors.orange;
      case 'caissier': return Colors.green;
      case 'admin': return Colors.blue;
      case 'beneficiaire':
      default: return Colors.grey.shade600;
    }
  }

  Widget _buildUserCard(String nom, String email, String role, Color roleColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor,
          foregroundColor: Colors.white,
          child: Text(role.substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(nom, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
              onPressed: () => Get.snackbar("Info", "La modification sera bientôt disponible."),
              tooltip: "Modifier",
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
              onPressed: () => Get.snackbar("Info", "La suppression sera bientôt disponible."),
              tooltip: "Supprimer",
            ),
          ],
        ),
      ),
    );
  }
}