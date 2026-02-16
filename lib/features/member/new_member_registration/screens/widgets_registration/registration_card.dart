import 'package:flutter/material.dart';
import '/core/constants/colors.dart';

class RegistrationCard extends StatelessWidget {
  final Widget child;
  final double bottomPadding; // To adjust scroll padding based on keyboard

  const RegistrationCard({
    super.key,
    required this.child,
    this.bottomPadding = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 70), // Fixed margins
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(24), child: child),
    );
  }
}
