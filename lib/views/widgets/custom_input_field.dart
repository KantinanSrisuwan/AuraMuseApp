import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final bool isPassword;
  final TextEditingController? controller; // ✅ เพิ่มตัวแปรรับค่า Controller

  const CustomInputField({
    super.key,
    required this.label,
    this.isPassword = false,
    this.controller, // ✅ เพิ่มใน Constructor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // ✅ เชื่อมต่อ Controller เข้ากับช่องพิมพ์
          obscureText: isPassword,
          style: const TextStyle(color: Colors.black), // เพิ่มให้สีตัวอักษรที่พิมพ์เป็นสีขาวด้วยครับ
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }
}