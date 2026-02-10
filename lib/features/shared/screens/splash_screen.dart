import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

// ✅ Core Imports
import '../../../core/constants/colors.dart';
import 'public_home_page.dart'; // Ensure path is correct

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ⏳ Wait 3 seconds, then Navigate
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PublicHomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to ensure we cover it all
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // We don't use backgroundColor here because the Container gradient covers it
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🔶 1. Gradient Background (Updated to use AppColors)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.44, 0.88],
                  colors: [
                    AppColors.primary, // Top: Saffron
                    Color(0xFFFFDB8E), // Mid: Bridge Color
                    AppColors.primaryLight, // Bottom: Cream
                  ],
                ),
              ),
            ),

            // 🚩 2. Background Flag (MANUALLY PULLED LEFT)
            Positioned(
              top: 0,
              bottom: 0,
              // 🔥 KEY FIX: Pull image 55px to the left to hide transparent gap
              left: -55,
              // Increase width slightly so it doesn't shrink
              width: screenWidth + 60,
              child: Opacity(
                opacity: 0.3, // Your requested opacity
                child: Image.asset(
                  'assets/images/saffron_flag_bg.png', // Ensure this file exists
                  fit: BoxFit.cover,
                  alignment: Alignment.topLeft,
                ),
              ),
            ),

            // 🕉️ 3. Center Text (Size 64, Stroke 3)
            Center(
              child: Stack(
                children: [
                  // Layer A: White Stroke
                  Text(
                    'धर्म योद्धा',
                    style: GoogleFonts.anekDevanagari(
                      fontSize: 64, // ✅ Kept your size
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth =
                            3 // ✅ Kept your stroke weight
                        ..color = AppColors.white.withValues(
                          alpha: 0.9,
                        ), // ✅ Using AppColors
                      shadows: const [
                        Shadow(
                          offset: Offset(2, 4),
                          blurRadius: 10,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  // Layer B: Orange Fill
                  Text(
                    'धर्म योद्धा',
                    style: GoogleFonts.anekDevanagari(
                      fontSize: 64, // ✅ Kept your size
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary, // ✅ Using AppColors.primary
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
