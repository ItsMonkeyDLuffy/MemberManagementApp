import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
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
    return AppBar(
      backgroundColor: const Color(0xFEFEFEFE), // slightly softer white
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 1),
      toolbarHeight: 70, // 🔥 gives breathing room inside
      automaticallyImplyLeading: false,
      titleSpacing: 15,

      // 🔻 Subtle curved bottom
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
      ),

      // 🕉️ LEFT CONTENT
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
          const SizedBox(width: 8),

          // Title (optically centered)
          Transform.translate(
            offset: const Offset(0, 6),
            child: Stack(
              children: [
                Text(
                  "धर्म योद्धा",
                  style: GoogleFonts.anekDevanagari(
                    fontSize: 28, // 🔥 slightly smaller & cleaner
                    fontWeight: FontWeight.w500,
                    height: 1,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1
                      ..color = Colors.white,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1.2),
                        blurRadius: 4,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                Text(
                  "धर्म योद्धा",
                  style: GoogleFonts.anekDevanagari(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    color: const Color(0xFFFF9933),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // 👉 RIGHT CONTENT
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: _buildAction(),
        ),
      ],
    );
  }

  Widget _buildAction() {
    switch (type) {
      case DharmaAppBarType.publicHome:
        return _actionButton("Login/Register");

      case DharmaAppBarType.login:
        return _actionButton("Admin Login");

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
        backgroundColor: const Color(0xFFFF9641),
        elevation: 2,

        minimumSize: const Size(0, 37),
        // 🔥 KEY PART — padding controls width
        padding: const EdgeInsets.symmetric(
          horizontal: 10, // 👈 controls width
          vertical: 7, // 👈 keeps height same
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(63);
}
