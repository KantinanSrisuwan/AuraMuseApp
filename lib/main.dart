import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';

void main() {
  runApp(const AuraMuseApp());
}

class AuraMuseApp extends StatelessWidget {
  const AuraMuseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraMuse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Kanit'),
      
      // ใช้ระบบ Named Routes แทนการระบุ home: ตรงๆ
      initialRoute: AppRoutes.login, 
      routes: AppRoutes.getRoutes(), 
    );
  }
}