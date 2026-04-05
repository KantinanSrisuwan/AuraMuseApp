import 'package:flutter/material.dart';
// ตรวจสอบชื่อหน้า Page ของ Admin ในโฟลเดอร์ views ของคุณนะครับ 
// สมมติว่าชื่อ AdminDashboardPage
import '../../views/admin/admin_dashboard.dart';
import '../../views/admin/admin_report.dart';
import '../../views/admin/admin_deck.dart';
import '../../views/admin/admin_user.dart';
import '../../views/admin/admin_verified.dart';
import '../../views/admin/admin_report_detail.dart';

class AdminRoutes {
  static const String adminDashboard = '/admin/dashboard';
  static const String adminReport = '/admin/report';
  static const String adminDeck = '/admin/deck';
  static const String adminUser = '/admin/user';
  static const String adminVerified = '/admin/verified';
  static const String adminReportDetail = '/admin/report_detail';
  // เพิ่ม path อื่นๆ ของ admin ที่นี่ เช่น /admin/settings

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      adminDashboard: (context) => const AdminDashboard(),
      adminReport: (context) => const AdminReport(),
      adminDeck: (context) => const AdminDeck(),
      adminUser: (context) => const AdminUser(),
      adminVerified: (context) => const AdminVerified(),
      adminReportDetail: (context) => const AdminReportDetailPage(),
    };
  }
}