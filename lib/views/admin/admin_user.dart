import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import '../../core/routes/admin_routes.dart';
import '../../services/firestore_service.dart';

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
            child: FutureBuilder(
              future: FirestoreService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'เกิดข้อผิดพลาด: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      'ไม่มีบัญชีผู้ใช้ในระบบ',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final createdAt = user['created_at'] != null
                        ? user['created_at'].toDate()
                        : DateTime.now();
                    return _buildUserItem(
                      userId: user['uid'] ?? '',
                      username: user['username'] ?? 'ไม่ระบุ',
                      dateCreated:
                          '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                      email: user['email'] ?? '',
                    );
                  },
                );
              },
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
    required String email,
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
            'email': email,
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