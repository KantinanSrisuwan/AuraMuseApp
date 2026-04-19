import 'package:flutter/material.dart';

class AppColors {
  // Primary Cosmic Colors
  static const Color backgroundNavy = Color(0xFF0F111E); // Deep cosmic dark navy
  static const Color backgroundNavyLight = Color(0xFF1E2135); // Slightly lighter navy
  static const Color cosmicPurple = Color(0xFF4B3B8A); // Softer magical purple
  static const Color cosmicCyan = Color(0xFF64B5F6); // Soft sky blue instead of neon cyan
  
  // Actions & States
  static const Color actionGreen = Color(0xFF4CAF50); // Muted green
  static const Color actionAmber = Color(0xFFFFCA28); // Soft glowing amber
  static const Color errorRed = Color(0xFFE57373); // Soft red
  
  // Text
  static const Color textWhite = Colors.white;
  static const Color textWhiteMuted = Colors.white70;
  static const Color textWhiteFaded = Colors.white30;

  // Glassmorphism & Inputs
  static const Color inputBackground = Color(0x0AFFFFFF); // 4% white
  static const Color glassBorder = Color(0x1EFFFFFF); // 12% white

  // Gradient: Cosmic Flow
  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [Color(0xFF392D69), Color(0xFF14142B)], // Darker, softer space hues
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient: Primary Action
  static const LinearGradient primaryActionGradient = LinearGradient(
    colors: [Color(0xFF64B5F6), Color(0xFF4B3B8A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Glassmorphism Decoration
  static BoxDecoration glassDecoration({double radius = 16}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.04), // translucent
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          spreadRadius: -5,
        ),
      ],
    );
  }
}