import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '/core/enums/app_bar_type.dart';

class DharmaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DharmaAppBarType type;
  final VoidCallback? onPrimaryAction;
  final Widget? customAction;
  final String? title;

  const DharmaAppBar({
    super.key,
    required this.type,
    this.onPrimaryAction,
    this.customAction,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final bool showBackButton =
        type == DharmaAppBarType.login || type == DharmaAppBarType.custom;

    return AppBar(
      backgroundColor: AppColors.white.withValues(alpha: 0.98),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.5), // Fixed alpha value
      toolbarHeight: 70,
      automaticallyImplyLeading: false,

      // ✅ BACK BUTTON (Still uses onPrimaryAction to go to Public Home)
      leadingWidth: showBackButton ? 60 : 0,
      leading: showBackButton
          ? Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                  size: 22,
                ),
                onPressed: () {
                  if (onPrimaryAction != null) {
                    onPrimaryAction!();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            )
          : null,

      titleSpacing: (title != null) ? 0 : (showBackButton ? 0 : 15),
      centerTitle: title != null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
      ),

      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.anekDevanagari(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(0, 6),
                  child: Stack(
                    children: [
                      Text(
                        "धर्म योद्धा",
                        style: GoogleFonts.anekDevanagari(
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1
                            ..color = AppColors.white,
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
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: AppColors.primary,
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
          // ✅ CHANGED: Logic decoupled from onPrimaryAction
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Admin Login coming soon!"),
                duration: Duration(seconds: 2),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          child: Center(
            child: Text(
              "Admin Login",
              style: GoogleFonts.anekDevanagari(
                color: AppColors.textSecondary,
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
        backgroundColor: AppColors.primary,
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
