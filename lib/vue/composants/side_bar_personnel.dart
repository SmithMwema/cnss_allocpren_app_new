import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SideBarPersonnel extends StatelessWidget {
  final String nom;
  final String email;
  final VoidCallback onDeconnexion;
  final List<Widget>? itemsSupplementaires;

  const SideBarPersonnel({
    super.key,
    required this.nom,
    required this.email,
    required this.onDeconnexion,
    this.itemsSupplementaires,
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
                child: Icon(Icons.person_outline, size: 40, color: Colors.white),
              ),
              decoration: const BoxDecoration(color: Color(0xff0d1b2a)),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: Colors.white70),
              title: const Text('Accueil', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
            if (itemsSupplementaires != null) ...itemsSupplementaires!,
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
}