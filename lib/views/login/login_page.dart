import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.cosmicGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: AppColors.glassDecoration(radius: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // โลโก้
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.cosmicGradient,
                    ),
                    child: Center(
                      child: Image.network(
                        'https://via.placeholder.com/80',
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
                      ),
                    ),
                  ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 20),
                  const Text(
                    "AURAMUSE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Welcome back to the cosmos",
                    style: TextStyle(
                      color: AppColors.textWhiteMuted,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 40),
            
           

                  // เอาคำว่า เข้าสู่ระบบ ออกเพราะดีไซน์ใหม่ให้โลโก้เด่นพอแล้ว

                  // Input Fields พร้อมตัวรับ Controller
                  CustomInputField(label: "EMAIL", controller: _emailController),
                  const SizedBox(height: 20),
                  CustomInputField(label: "PASSWORD", isPassword: true, controller: _passwordController),
                  
                  const SizedBox(height: 10),
            
            // ลิงก์สมัครสมาชิก
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                      child: const Text(
                        "ยังไม่มีบัญชีใช่ไหม?",
                        style: TextStyle(
                          color: AppColors.cosmicCyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ปุ่ม Login พร้อมระบบ Loading
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryActionGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cosmicCyan.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "เข้าสู่ระบบ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}