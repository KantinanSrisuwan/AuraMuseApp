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
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white), 
          cursorColor: AppColors.cosmicCyan,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassBorder, // Translucent background
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cosmicCyan, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}