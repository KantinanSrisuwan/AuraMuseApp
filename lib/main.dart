import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/admin_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 4. สั่งเริ่มการทำงานของ Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AuraMuseApp());
}

class AuraMuseApp extends StatelessWidget {
  const AuraMuseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraMuse',
      debugShowCheckedModeBanner: false,
      
      initialRoute: AppRoutes.login, 
      routes: {
        ... AppRoutes.getRoutes(), 
        ... AdminRoutes.getRoutes(),
      },
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}