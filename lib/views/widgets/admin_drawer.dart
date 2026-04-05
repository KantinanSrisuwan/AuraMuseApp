import 'package:flutter/material.dart';
import '../../core/routes/admin_routes.dart';
import '../../core/routes/app_routes.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute; // รับค่าว่าตอนนี้อยู่หน้าไหน

  const AdminDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 60, bottom: 20),
            child: Text(
              "Menu",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000080),
              ),
            ),
          ),
          // เรียกใช้เมนูต่างๆ
          _menuItem(context, Icons.home, "Home", AdminRoutes.adminDashboard),
          _menuItem(context, Icons.description, "Report", AdminRoutes.adminReport),
          _menuItem(context, Icons.style, "Deck", AdminRoutes.adminDeck),
          _menuItem(context, Icons.person, "User", ""),
          _menuItem(context, Icons.check_circle_outline, "Verified", ""),
          
          const Spacer(), // ดัน Logout ไปล่างสุด
          
          _buildLogoutBtn(context),
        ],
      ),
    );
  }

  // Widget ย่อยสำหรับแต่ละเมนู
  Widget _menuItem(BuildContext context, IconData icon, String title, String routeName) {
    bool isActive = currentRoute == title; // เช็คเพื่อทำ Highlight

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isActive ? const Color(0xFFA288F8) : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.white : Colors.black87,
          size: 30,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
        onTap: () {
          if (routeName.isNotEmpty && !isActive) {
            Navigator.pushReplacementNamed(context, routeName);
          } else {
            Navigator.pop(context); // ถ้าเป็นหน้าเดิมหรือไม่มีรูท ให้แค่ปิด Drawer
          }
        },
      ),
    );
  }

  // Widget สำหรับปุ่ม Logout
  Widget _buildLogoutBtn(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      },
      child: const Padding(
        padding: EdgeInsets.only(left: 20, bottom: 40, top: 20),
        child: Row(
          children: [
            Icon(Icons.meeting_room_outlined, color: Color(0xFF3B2F71), size: 30),
            SizedBox(width: 20),
            Text(
              "LOGOUT",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B2F71),
              ),
            ),
          ],
        ),
      ),
    );
  }
}