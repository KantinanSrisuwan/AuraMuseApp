import 'package:flutter/material.dart';
// ตรวจสอบชื่อหน้า Page ของ Admin ในโฟลเดอร์ views ของคุณนะครับ 
// สมมติว่าชื่อ AdminDashboardPage
import '../../views/admin/admin_dashboard.dart';
import '../../views/admin/admin_report.dart';
import '../../views/admin/admin_deck.dart';
import '../../views/admin/admin_user.dart';
import '../../views/admin/admin_verified.dart';
import '../../views/admin/admin_report_detail.dart';
import '../../views/admin/admin_deck_detail.dart';
import '../../views/admin/admin_user_detail.dart';
import '../../views/admin/admin_verify_deck.dart';
import '../../views/admin/admin_edit_user.dart';

class AdminRoutes {
  static const String adminDashboard = '/admin/dashboard';
  static const String adminReport = '/admin/report';
  static const String adminDeck = '/admin/deck';
  static const String adminUser = '/admin/user';
  static const String adminVerified = '/admin/verified';
  static const String adminReportDetail = '/admin/report_detail';
  static const String adminDeckDetail = '/admin/deck_detail';
  static const String adminUserDetail = '/admin/user_detail';
  static const String adminVerifyDetail = '/admin/verify_detail';
  static const String adminEditUser = '/admin/edit_user';
  // เพิ่ม path อื่นๆ ของ admin ที่นี่ เช่น /admin/settings

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      adminDashboard: (context) => const AdminDashboard(),
      adminReport: (context) => const AdminReport(),
      adminDeck: (context) => const AdminDeck(),
      adminUser: (context) => const AdminUser(),
      adminVerified: (context) => const AdminVerified(),
      adminReportDetail: (context) => const AdminReportDetailPage(),
      adminDeckDetail: (context) => const AdminDeckDetailPage(),
      adminVerifyDetail: (context) => const AdminVerifyDeckPage(),
      adminUserDetail: (context) => const AdminUserDetailPage(),
      adminEditUser: (context) => const AdminEditUserPage(),
    };
  }
}