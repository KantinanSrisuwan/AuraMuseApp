import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_input_field.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
            const CustomInputField(label: "NAME"),
            const SizedBox(height: 20),
            const CustomInputField(label: "USERNAME"),
            const SizedBox(height: 20),
            const CustomInputField(label: "PASSWORD", isPassword: true),
            const SizedBox(height: 20),
            const CustomInputField(label: "CONFIRM PASSWORD", isPassword: true),
            const SizedBox(height: 60),
            // ปุ่มลงทะเบียน
            SizedBox(
              width: 250,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Logic สำหรับสมัครสมาชิกในอนาคต
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.actionGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
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