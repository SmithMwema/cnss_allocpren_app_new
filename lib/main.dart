// lib/main.dart

// --- LA CORRECTION EST ICI. CET IMPORT DÉFINIT TOUTES LES FONCTIONS DE BASE DE FLUTTER ---
import 'package:flutter/material.dart';
// --------------------------------------------------------------------------------------

import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'routes/app_pages.dart';
import 'service/auth_service.dart';
import 'service/firestore_service.dart';

Future<void> main() async {
  // Cette ligne ne causera plus d'erreur car elle est définie dans 'material.dart'
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('fr_FR', null);
  
  initialiserServices();
  
  // Cette fonction ne causera plus d'erreur
  runApp(const MyApp());
}

void initialiserServices() {
  Get.put(FirestoreService(), permanent: true); 
  Get.put(AuthService(), permanent: true); 
}

// Les classes StatelessWidget et BuildContext ne causeront plus d'erreur
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('fr', 'FR'),
      title: 'CNSS App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        cardColor: Colors.white,
        dialogBackgroundColor: Colors.grey.shade100,
        colorScheme: const ColorScheme.light(
          primary: Color(0xff1b263b),
          secondary: Color(0xff26a69a),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        cardColor: const Color(0xff415a77),
        dialogBackgroundColor: const Color(0xff1b263b),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff415a77),
          secondary: Color(0xff00a99d),
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: AppPages.lancement,
      getPages: AppPages.routes,
    );
  }
}