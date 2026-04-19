import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Unknown";
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return "Unknown";
    }
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundNavy,
        body: Center(child: Text("Not Logged In")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.cosmicCyan));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User data not found', style: TextStyle(color: Colors.white)));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: AppColors.backgroundNavy,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 1. ส่วนข้อมูลโปรไฟล์ด้านบน
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProfileHeader(userData),
                  ),
                  
                  const SizedBox(height: 30),

                  // 2. กลุ่มปุ่มเมนู (แก้ไขบัญชี, การแจ้งเตือน, ข้อกำหนด)
                  _buildMenuButton(
                    context, 
                    icon: Icons.account_circle_outlined, 
                    title: "แก้ไขบัญชี", 
                    route: AppRoutes.editAccount
                  ),
                  _buildMenuButton(
                    context, 
                    icon: Icons.notifications_none_outlined, 
                    title: "การแจ้งเตือน", 
                    route: AppRoutes.notifications
                  ),
                  _buildMenuButton(
                    context, 
                    icon: Icons.menu_book_outlined, 
                    title: "ข้อกำหนดของแพลตฟอร์ม", 
                    route: AppRoutes.terms
                  ),

                  const SizedBox(height: 20),
                  
                  // 3. ปุ่ม Logout 
                  _buildMenuButton(
                    context, 
                    icon: Icons.logout, 
                    title: "LOGOUT", 
                    isLogout: true
                  ),
                  
                  const SizedBox(height: 100), // พื้นที่ป้องกัน navbar บัง
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> data) {
    final uid = data['uid'] ?? 'Unknown';
    final shortUid = uid.length > 6 ? uid.substring(0, 6) : uid;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: AppColors.glassDecoration(radius: 20).copyWith(
        border: Border.all(color: AppColors.cosmicCyan.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          // รูปโปรไฟล์ (ไอคอนแทนรูปจริง)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cosmicCyan.withOpacity(0.5), width: 2),
            ),
            child: const CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.backgroundNavyLight,
              child: Icon(Icons.person_rounded, size: 40, color: AppColors.cosmicCyan),
            ),
          ),
          const SizedBox(width: 20),
          // ข้อมูล Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("หมายเลข user : $shortUid", style: const TextStyle(color: AppColors.textWhiteMuted, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  data['username'] ?? "User", 
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data['email'] ?? "No Email", 
                  style: const TextStyle(color: AppColors.textWhiteMuted, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text("วันที่สร้างบัญชี : ${_formatDate(data['created_at'])}", style: const TextStyle(color: AppColors.textWhiteMuted, fontSize: 12)),
                Text("จำนวนสำรับทั้งหมด : ${data['total_decks_created'] ?? 0}", style: const TextStyle(color: AppColors.textWhiteMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required IconData icon, required String title, String? route, bool isLogout = false}) {
    final color = isLogout ? AppColors.errorRed : AppColors.textWhite;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: AppColors.glassDecoration(radius: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (isLogout) {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            } else if (route != null) {
              Navigator.pushNamed(context, route);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}