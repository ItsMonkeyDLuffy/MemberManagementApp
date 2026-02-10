import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart'; // ✅ Using your AppColors
import '/core/enums/app_bar_type.dart';

class DharmaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DharmaAppBarType type;
  final VoidCallback? onPrimaryAction;
  final Widget? customAction;

  const DharmaAppBar({
    super.key,
    required this.type,
    this.onPrimaryAction,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    // Logic for back button
    final bool showBackButton =
        type == DharmaAppBarType.login || type == DharmaAppBarType.custom;

    return AppBar(
      // ✅ Use AppColors.white (with your specific opacity if needed)
      backgroundColor: AppColors.white.withValues(alpha: 0.98),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 5),
      toolbarHeight: 70,

      automaticallyImplyLeading: false,
      leadingWidth: showBackButton ? 60 : 0,
      leading: showBackButton
          ? Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary, // ✅ Swapped to AppColors.primary
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,

      titleSpacing: showBackButton ? 0 : 15,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
      ),

      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, 6),
            child: Stack(
              children: [
                // 1. OUTLINE LAYER (Stroke)
                Text(
                  "धर्म योद्धा",
                  // ✅ EXACT SAME STYLE, just swapped color to AppColors
                  style: GoogleFonts.anekDevanagari(
                    fontSize: 35, // 🔒 KEEPS YOUR SIZE
                    fontWeight: FontWeight.w700, // 🔒 KEEPS YOUR WEIGHT
                    height: 1,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1
                      ..color = AppColors.white, // ✅ Swapped to AppColors
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1.2),
                        blurRadius: 4,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),

                // 2. FILL LAYER (Solid Color)
                Text(
                  "धर्म योद्धा",
                  // ✅ EXACT SAME STYLE
                  style: GoogleFonts.anekDevanagari(
                    fontSize: 35, // 🔒 KEEPS YOUR SIZE
                    fontWeight: FontWeight.w700, // 🔒 KEEPS YOUR WEIGHT
                    height: 1,
                    color: AppColors.primary, // ✅ Swapped to AppColors.primary
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: _buildAction(context),
        ),
      ],
    );
  }

  Widget _buildAction(BuildContext context) {
    switch (type) {
      case DharmaAppBarType.publicHome:
        return _actionButton("Login/Register");

      case DharmaAppBarType.login:
        return GestureDetector(
          onTap: onPrimaryAction,
          child: Center(
            child: Text(
              "Admin Login",
              style: GoogleFonts.anekDevanagari(
                color: AppColors.textSecondary, // ✅ Swapped to AppColors
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );

      case DharmaAppBarType.dashboard:
        return IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: onPrimaryAction,
        );

      case DharmaAppBarType.custom:
        return customAction ?? const SizedBox();

      default:
        return const SizedBox();
    }
  }

  Widget _actionButton(String label) {
    return ElevatedButton(
      onPressed: onPrimaryAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // ✅ Swapped to AppColors
        foregroundColor: AppColors.white,
        elevation: 2,
        minimumSize: const Size(0, 37),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
