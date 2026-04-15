import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/custom_input_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // สร้าง Controller มารับค่า Email, Name, Password, Confirm Password
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // ฟังก์ชันจัดการการลงทะเบียน
  Future<void> _handleRegister() async {
    // 1. ตรวจสอบว่าเต็มไหม
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showError("กรุณากรอกข้อมูลให้ครบถ้วน");
      return;
    }

    // 2. ตรวจสอบว่ารหัสผ่านตรงกันไหม
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("รหัสผ่านไม่ตรงกัน");
      return;
    }

    // 3. ตรวจสอบความยาวรหัสผ่าน
    if (_passwordController.text.length < 6) {
      _showError("รหัสผ่านต้องมี 6 ตัวอักษรขึ้นไป");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 4. สร้างบัญชี Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 5. บันทึกข้อมูล user ใน Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'username': _nameController.text.trim(), // ชื่อที่ใช้แสดงในแอป
        'email': _emailController.text.trim(),
        'role': 'user', // ตั้งค่า role เป็น user ปกติ
        'created_at': FieldValue.serverTimestamp(),
        'favorites': [], // เก็บ Deck IDs ที่ถูกใจ
        'quick_draws': [], // เก็บ Deck IDs ที่กดสายฟ้า
        'my_decks': [], // เก็บ Deck IDs ที่ user สร้าง
        'total_decks_created': 0, // จำนวน Deck ที่สร้าง
      });

      if (!mounted) return;

      // 6. แสดงข้อความสำเร็จ
      _showSuccess("ลงทะเบียนสำเร็จ! กำลังพานำท่านไปหน้า login...");

      // 7. นำไปหน้า Login หลัง 2 วินาที
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
    } on FirebaseAuthException catch (e) {
      String errorMsg = "เกิดข้อผิดพลาด";

      if (e.code == 'weak-password') {
        errorMsg = "รหัสผ่านไม่พอแรง";
      } else if (e.code == 'email-already-in-use') {
        errorMsg = "อีเมลนี้ถูกใช้ไปแล้ว";
      } else if (e.code == 'invalid-email') {
        errorMsg = "รูปแบบอีเมลไม่ถูกต้อง";
      } else {
        errorMsg = e.message ?? "เกิดข้อผิดพลาดในการลงทะเบียน";
      }

      _showError(errorMsg);
    } catch (e) {
      _showError("เกิดข้อผิดพลาด: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.actionGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      // ปุ่มย้อนกลับ (Back Button)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "สมัครสมาชิก",
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // ช่องกรอกข้อมูลสำหรับสมัครสมาชิก
            CustomInputField(label: "NAME", controller: _nameController),
            const SizedBox(height: 20),
            CustomInputField(label: "EMAIL", controller: _emailController),
            const SizedBox(height: 20),
            CustomInputField(
              label: "PASSWORD",
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 20),
            CustomInputField(
              label: "CONFIRM PASSWORD",
              isPassword: true,
              controller: _confirmPasswordController,
            ),
            const SizedBox(height: 60),
            // ปุ่มลงทะเบียน
            SizedBox(
              width: 250,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.actionGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "ลงทะเบียน",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}