import 'package:flutter/material.dart';
import '../../views/login/login_page.dart';
import '../../views/login/register_page.dart';
import '../../views/home/home_page.dart'; // เพิ่ม import หน้า Home
import '../../../views/home/draw_result_page.dart';

class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String home = '/home';
  static const String drawResult = '/draw_result';
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      home: (context) => const HomePage(), // ลงทะเบียนหน้า Home
      drawResult: (context) => const DrawResultPage(deckName: "Dummy"),
    };
  }
}