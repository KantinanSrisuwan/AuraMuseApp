import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_input_field.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNavy,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            const SizedBox(height: 80),
            // Logo Section
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
                      'https://via.placeholder.com/80', // ใส่ URL รูปโลโก้ของคุณที่นี่
                      color: Colors.white,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
                    ),
                    const Text("AURAMUSE", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "เข้าสู่ระบบ",
              style: TextStyle(color: AppColors.textWhite, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Input Fields
            const CustomInputField(label: "USERNAME"),
            const SizedBox(height: 20),
            const CustomInputField(label: "PASSWORD", isPassword: true),
            const SizedBox(height: 10),
            // Register Link
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
              onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => const RegisterPage()),);
              },
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
            // Login Button
            SizedBox(
              width: 250,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Navigation จะถูกใส่ที่นี่ในอนาคต
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.actionGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "เข้าสู่ระบบ",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}