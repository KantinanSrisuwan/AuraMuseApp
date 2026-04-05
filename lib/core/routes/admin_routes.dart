import 'package:flutter/material.dart';
// ตรวจสอบชื่อหน้า Page ของ Admin ในโฟลเดอร์ views ของคุณนะครับ 
// สมมติว่าชื่อ AdminDashboardPage
import '../../views/admin/admin_dashboard.dart';
import '../../views/admin/admin_report.dart';
import '../../views/admin/admin_deck.dart';

class AdminRoutes {
  static const String adminDashboard = '/admin/dashboard';
  static const String adminReport = '/admin/report';
  static const String adminDeck = '/admin/deck';
  // เพิ่ม path อื่นๆ ของ admin ที่นี่ เช่น /admin/settings

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      adminDashboard: (context) => const AdminDashboard(),
      adminReport: (context) => const AdminReport(),
      adminDeck: (context) => const AdminDeck(),
    };
  }
}