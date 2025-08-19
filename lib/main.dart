import 'package:flutter/material.dart';
// LIGNE CORRIGÉE
import 'package:get/get.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'routes/app_pages.dart';
import 'service/auth_service.dart';
import 'service/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('fr_FR', null);
  
  initialiserServices();
  
  runApp(const MyApp());
}

void initialiserServices() {
  Get.put(FirestoreService(), permanent: true); 
  Get.put(AuthService(), permanent: true); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
      
      locale: const Locale('fr', 'FR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      
      initialRoute: AppPages.lancement,
      getPages: AppPages.routes,
    );
  }
}