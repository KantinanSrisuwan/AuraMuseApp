import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/admin_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 4. สั่งเริ่มการทำงานของ Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AuraMuseApp());
}

class AuraMuseApp extends StatelessWidget {
  const AuraMuseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraMuse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundNavy,
        textTheme: GoogleFonts.promptTextTheme(Theme.of(context).textTheme)
            .apply(
              bodyColor: AppColors.textWhite,
              displayColor: AppColors.textWhite,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.cosmicCyan,
          secondary: AppColors.cosmicPurple,
          surface: AppColors.backgroundNavyLight,
        ),
      ),
      initialRoute: AppRoutes.login,
      routes: {...AppRoutes.getRoutes(), ...AdminRoutes.getRoutes()},
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
