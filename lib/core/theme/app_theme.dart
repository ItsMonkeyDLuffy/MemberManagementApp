import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // 1. GLOBAL COLORS
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        surface: AppColors.white,
        error: AppColors.error,
      ),

      // 2. BACKGROUND
      // We set this to your Cream color so screens without the gradient
      // still look correct (instead of stark white).
      scaffoldBackgroundColor: AppColors.primaryLight,

      // 3. TYPOGRAPHY (Anek Devanagari Everywhere)
      textTheme: GoogleFonts.anekDevanagariTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),

      // 4. BUTTON THEME (Matches your "Login/Register" button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Your rounded corners
          ),
          textStyle: GoogleFonts.anekDevanagari(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 5. INPUT THEME (Matches your Login Fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      // 6. ICON THEME
      iconTheme: const IconThemeData(color: AppColors.primary),
    );
  }
}
