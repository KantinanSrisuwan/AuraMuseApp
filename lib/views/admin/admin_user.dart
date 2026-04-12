import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import '../../core/routes/admin_routes.dart';

class AdminUser extends StatefulWidget {
  const AdminUser({super.key});

  @override
  State<AdminUser> createState() => _AdminUserState();
}

class _AdminUserState extends State<AdminUser> {
  // ใช้ GlobalKey เพื่อให้มั่นใจว่าปุ่มเบอร์เกอร์บาร์กดติดแน่นอน
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF13112B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 30),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      // ไฮไลท์ที่เมนู 'User'
      drawer: const AdminDrawer(currentRoute: 'User'),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "บัญชีทั้งหมด",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildUserItem(
                  userId: "1082",
                  username: "ราชาคนุษยัยามดึก",
                  dateCreated: "08/03/2026",
                ),
                _buildUserItem(
                  userId: "1083",
                  username: "แมค โดนัล",
                  dateCreated: "06/03/2026",
                ),
                // สามารถเพิ่ม User อื่นๆ ตรงนี้
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับบล็อกข้อมูลผู้ใช้งาน
  Widget _buildUserItem({
    required String userId,
    required String username,
    required String dateCreated,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AdminRoutes.adminUserDetail, // ตรวจสอบชื่อ Route ใน admin_routes.dart นะครับ
          arguments: {
            'userId': userId,
            'username': username,
            'dateCreated': dateCreated,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFF13112B), width: 8),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ไอคอนรูปบัญชี/โปรไฟล์ด้านซ้าย
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.account_box_outlined, color: Colors.black, size: 60),
            ),
            const SizedBox(width: 15),
            // ข้อมูล User ด้านขวา
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    "หมายเลข user : $userId",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Username : $username",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "วันที่สร้างบัญชี : $dateCreated",
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}