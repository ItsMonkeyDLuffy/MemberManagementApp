import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Added for session check

// ✅ Core Imports
import '../../../core/constants/colors.dart';
import 'package:member_management_app/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ⏳ Wait 3 seconds, then Navigate based on Auth Status
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // ✅ NEW LOGIC: Check if user is already logged in
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // 🚀 Already Logged In: Go to AuthWrapper (Login Route)
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else {
          // 🏠 Not Logged In: Go to Public Home Page
          Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to ensure we cover it all
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🔶 1. Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.44, 0.88],
                  colors: [
                    AppColors.primary,
                    Color(0xFFFFDB8E),
                    AppColors.primaryLight,
                  ],
                ),
              ),
            ),

            // 🚩 2. Background Flag
            Positioned(
              top: 0,
              bottom: 0,
              left: -55,
              width: screenWidth + 60,
              child: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  'assets/images/saffron_flag_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topLeft,
                ),
              ),
            ),

            // 🕉️ 3. Center Text
            Center(
              child: Stack(
                children: [
                  Text(
                    'धर्म योद्धा',
                    style: GoogleFonts.anekDevanagari(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3
                        ..color = AppColors.white.withValues(alpha: 0.9),
                      shadows: const [
                        Shadow(
                          offset: Offset(2, 4),
                          blurRadius: 10,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'धर्म योद्धा',
                    style: GoogleFonts.anekDevanagari(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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
