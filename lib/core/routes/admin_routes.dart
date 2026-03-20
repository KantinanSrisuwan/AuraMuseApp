import 'package:flutter/material.dart';
import '../../../views/login/login_page.dart';
import '../../../views/login/register_page.dart';
// import '../../../views/home/home_page.dart'; // เตรียมไว้สำหรับหน้าถัดไป

class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String home = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      // home: (context) => const HomePage(), 
    };
  }
}