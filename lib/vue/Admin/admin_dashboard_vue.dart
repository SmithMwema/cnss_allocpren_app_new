import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controleur/admin_dashboard_ctrl.dart';
import 'widgets/page_admin_dashboard.dart';
import 'widgets/page_creer_utilisateur.dart';
import 'widgets/page_parametres.dart';

class AdminDashboardVue extends StatelessWidget {
  const AdminDashboardVue({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminDashboardCtrl ctrl = Get.put(AdminDashboardCtrl());
    
    final List<Widget> pages = [
      const PageAdminDashboard(),
      const PageCreerUtilisateur(),
      const PageParametres(),
    ];

    return Scaffold(
      drawer: Obx(() => _SideBarAdmin(
        nom: ctrl.nomUtilisateur.value,
        email: ctrl.emailUtilisateur.value,
        onDeconnexion: ctrl.seDeconnecter,
      )),
      appBar: AppBar(
        title: Obx(() => Text(
          ctrl.selectedIndex.value == 1 ? "Gestion Utilisateurs" : 
          ctrl.selectedIndex.value == 2 ? "Paramètres" : "Tableau de Bord Admin"
        )),
        backgroundColor: const Color(0xff0d1b2a),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: ctrl.selectedIndex.value,
        backgroundColor: Colors.transparent,
        color: const Color(0xff1b263b),
        buttonBackgroundColor: const Color(0xff1b263b),
        height: 60,
        items: const <Widget>[
          Icon(Icons.dashboard_outlined, size: 30, color: Colors.white),
          Icon(Icons.people_alt_outlined, size: 30, color: Colors.white),
          Icon(Icons.settings_outlined, size: 30, color: Colors.white),
        ],
        onTap: ctrl.changePage,
      ),
      body: Obx(() => pages[ctrl.selectedIndex.value]),
    );
  }
}

class _SideBarAdmin extends StatelessWidget {
  final String nom;
  final String email;
  final VoidCallback onDeconnexion;

  const _SideBarAdmin({
    required this.nom,
    required this.email,
    required this.onDeconnexion,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xff1b263b),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(nom, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              accountEmail: Text(email),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Color(0xff00a99d),
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
              ),
              decoration: const BoxDecoration(color: Color(0xff0d1b2a)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: Colors.white70),
              title: const Text('Tableau de bord', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
            
            // --- ON RAJOUTE L'OPTION POUR CHANGER LE THÈME ---
            ListTile(
              leading: const Icon(Icons.palette_outlined, color: Colors.white70),
              title: const Text('Changer de Thème', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back(); // Ferme le drawer
                _afficherDialogueTheme(context);
              },
            ),
            
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text('Se déconnecter', style: TextStyle(color: Colors.white)),
              onTap: onDeconnexion,
            ),
          ],
        ),
      ),
    );
  }

  // --- ON AJOUTE LA MÉTHODE POUR LE DIALOGUE DE THÈME ---
  void _afficherDialogueTheme(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Text("Choisir un thème", style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Thème Clair"),
                onTap: () { Get.changeThemeMode(ThemeMode.light); Get.back(); },
              ),
              ListTile(
                title: const Text("Thème Sombre"),
                onTap: () { Get.changeThemeMode(ThemeMode.dark); Get.back(); },
              ),
            ],
          ),
        );
      },
    );
  }
}