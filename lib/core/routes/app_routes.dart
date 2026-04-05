import 'package:flutter/material.dart';
// 1. เพิ่ม Import MainWrapper (ตัวคุมหน้าจอหลัก)
import 'package:project_flutter/views/main_wrapper.dart'; 

// Import หน้าอื่นๆ (ใช้ Package Path จะไม่งงเรื่องจุดครับ)
import 'package:project_flutter/views/login/login_page.dart';
import 'package:project_flutter/views/login/register_page.dart';
import 'package:project_flutter/views/home/draw_result_page.dart';

class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String mainWrapper = '/main'; // หน้าหลักหลัง Login
  static const String drawResult = '/draw_result';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      mainWrapper: (context) => const MainWrapper(),
      drawResult: (context) => const DrawResultPage(deckName: ''), 
    };
  }
}