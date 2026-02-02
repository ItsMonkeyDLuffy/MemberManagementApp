import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.44, 0.88],
          colors: [
            Color(0xFFFFA05C), // Top Orange
            Color(0xFFFFDB8E), // Mid
            Color(0xFFFFE8B7), // Bottom Cream
          ],
        ),
      ),
      child: child,
    );
  }
}
