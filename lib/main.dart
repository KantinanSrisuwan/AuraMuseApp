import 'package:flutter/material.dart';
import 'views/login/login_page.dart';

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
      theme: ThemeData(
        fontFamily: 'Kanit', // หรือฟอนต์ที่คุณต้องการ
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // กำหนดหน้าแรกเป็น LoginPage
    );
  }
}