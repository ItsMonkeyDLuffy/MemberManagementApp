import 'package:flutter/material.dart';

class AppColors {
  // --------------------------------------
  // BRAND COLORS (Raw Palette)
  // --------------------------------------
  static const Color primary = Color(0xFFFF9641); // Main Saffron
  static const Color primaryDark = Color(0xFFF4A261); // Darker Orange
  static const Color primaryLight = Color(0xFFFFE8C3); // Cream/Light Orange
  static const Color accentBeige = Color(0xFFE3D5B0); // Gold/Beige

  // --------------------------------------
  // SEMANTIC ALIASES (This fixes your error)
  // --------------------------------------
  // ✅ This line defines 'background' as your cream color
  static const Color background = primaryLight;

  // ✅ This defines the border color for input fields
  static const Color fieldBorder = Colors.black12;

  // --------------------------------------
  // UI COLORS
  // --------------------------------------
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
}
