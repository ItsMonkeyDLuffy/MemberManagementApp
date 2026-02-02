import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <--- Import added
import '../constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Global Colors
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor:
          AppColors.background, // Cream background globally
      // ✅ TEXT THEME: Anek Devanagari applied globally
      textTheme: GoogleFonts.anekDevanagariTextTheme()
          .apply(
            bodyColor:
                AppColors.textPrimary, // Applies to bodyLarge, bodyMedium, etc.
            displayColor:
                AppColors.textPrimary, // Applies to headlines, titles, etc.
          )
          .copyWith(
            // We can still override specific styles if needed, merging with the font
            titleLarge: GoogleFonts.anekDevanagari(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22, // Standardizing title size
            ),
          ),

      // AppBar Theme (Transparent with Brown Text)
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.anekDevanagari(
          // Ensure AppBar uses the font too
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Button Theme (Saffron Background, White Text)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.anekDevanagari(
            // Font for buttons
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),

      // Input Field Theme (White box with Orange border)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
