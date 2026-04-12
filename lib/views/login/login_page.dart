import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/admin_routes.dart';
import '../widgets/custom_input_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // สร้าง Controller มารับค่า Email และ Password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // ฟังก์ชันจัดการการ Login และตรวจสอบ Role
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("กรุณากรอกข้อมูลให้ครบถ้วน");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. เข้าสู่ระบบด้วย Email/Password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. ดึงข้อมูล Role จาก Firestore คอลเลกชัน 'User'
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc.get('role');

        if (!mounted) return;

        // 3. แยกเส้นทางตาม Role
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, AdminRoutes.adminDashboard);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.mainWrapper);
        }
      } else {
        throw "ไม่พบข้อมูลผู้ใช้ในระบบฐานข้อมูล";
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "อีเมลหรือรหัสผ่านไม่ถูกต้อง");
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            const SizedBox(height: 80),
            
            // ✅ โลโก้เดิมของท่านเป๊ะๆ กลับมาแล้วครับ!
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: AppColors.cosmicGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://via.placeholder.com/80',
                      color: Colors.white,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
                    ),
                    const Text("AURAMUSE",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "เข้าสู่ระบบ",
              style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Input Fields พร้อมตัวรับ Controller
            CustomInputField(label: "EMAIL", controller: _emailController),
            const SizedBox(height: 20),
            CustomInputField(label: "PASSWORD", isPassword: true, controller: _passwordController),
            
            const SizedBox(height: 10),
            
            // ลิงก์สมัครสมาชิก
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                child: const Text(
                  "ยังไม่มีบัญชีใช่ไหม?",
                  style: TextStyle(
                    color: Colors.white70,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),

            // ปุ่ม Login พร้อมระบบ Loading
            SizedBox(
              width: 250,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.actionGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "เข้าสู่ระบบ",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}