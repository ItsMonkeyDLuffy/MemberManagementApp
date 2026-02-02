import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

// ✅ UNCOMMENT or ADD the correct import for your Home Page
import 'public_home_page.dart';

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
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PublicHomePage()),
      );
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
                    Color(0xFFFFA05C),
                    Color(0xFFFFDB8E),
                    Color(0xFFFFE8B7),
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
                  'assets/images/saffron_flag_bg.png',
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
                        ..color = const Color(0xEEEEEEEE),
                      shadows: [
                        Shadow(
                          offset: const Offset(2, 4),
                          blurRadius: 10,
                          color: Colors.black26,
                        ), // Safe opacity method
                      ],
                    ),
                  ),
                  // Layer B: Orange Fill
                  Text(
                    'धर्म योद्धा',
                    style: GoogleFonts.anekDevanagari(
                      fontSize: 64, // ✅ Kept your size
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 143, 31),
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
