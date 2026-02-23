import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core/constants/colors.dart';
import '/core/widgets/dharma_app_bar.dart';
import '/core/enums/app_bar_type.dart';
import '/core/widgets/gradient_background.dart';

class RegistrationWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;

  const RegistrationWrapper({super.key, required this.child, this.onBack});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double topBarrierHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return GestureDetector(
      // Global touch to close keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: DharmaAppBar(
          type: DharmaAppBarType.custom,
          onPrimaryAction: onBack ?? () => Navigator.pop(context),
        ),
        body: Stack(
          children: [
            // 1. BACKGROUND
            Positioned.fill(
              child: GradientBackground(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: topBarrierHeight + 15,
                      bottom: 0,
                      left: -42,
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
                  ],
                ),
              ),
            ),

            // 2. CHILD CONTENT (The Card)
            Positioned.fill(top: topBarrierHeight + 50, child: child),

            // 3. BOTTOM FOOTER
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Need Help?",
                    style: GoogleFonts.anekDevanagari(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
