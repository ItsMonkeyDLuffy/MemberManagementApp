import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensures it covers the whole screen width
      height: double.infinity, // Ensures it covers the whole screen height
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // ✅ These exact stops create the smooth 3-tone fade
          stops: [0.0, 0.49, 0.88],
          colors: [
            Color(0xFFFFA05C), // Top: Bright Saffron Orange
            Color(0xFFFFDB8E), // Mid: Soft Gold/Yellow (The Bridge)
            Color(0xFFFFE8B7), // Bottom: Light Cream
          ],
        ),
      ),
      child: child,
    );
  }
}
