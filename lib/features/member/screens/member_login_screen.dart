import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ✅ Logic & Core
import '../../auth/logic/auth_controller.dart';
import '../../member/screens/otp_screen.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/dharma_app_bar.dart';
import '../../../core/enums/app_bar_type.dart';
import '../../../core/widgets/gradient_background.dart';

// 👇 IMPORT YOUR PUBLIC HOME SCREEN HERE
import 'package:member_management_app/features/shared/screens/public_home_page.dart';

class MemberLoginScreen extends StatefulWidget {
  const MemberLoginScreen({super.key});

  @override
  State<MemberLoginScreen> createState() => _MemberLoginScreenState();
}

class _MemberLoginScreenState extends State<MemberLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isPhoneValid = true;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // 📏 MEASUREMENTS
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double topBarrierHeight = statusBarHeight + appBarHeight;

    // ✅ HANDLE BACK BUTTON LOGIC
    // We use PopScope to catch system back gestures (Android swipe)
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Explicitly go to Public Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PublicHomePage()),
        );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,

        appBar: DharmaAppBar(
          type: DharmaAppBarType.login,
          // ✅ EXPLICIT NAVIGATION (Fixes Crash/Minimize)
          onPrimaryAction: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PublicHomePage()),
            );
          },
        ),

        body: Stack(
          children: [
            // ============================================
            // LAYER 1: STATIC BACKGROUND & FOOTER
            // ============================================
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

                    // FOOTER
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Need Help?",
                              style: GoogleFonts.anekDevanagari(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 1),
                          _buildSocialIcons(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ============================================
            // LAYER 2: INTERACTIVE UI
            // ============================================
            Column(
              children: [
                SizedBox(height: topBarrierHeight),

                Expanded(
                  child: Align(
                    alignment: const Alignment(0.0, -0.2),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(
                          vertical: 23,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "MEMBER LOGIN",
                              style: GoogleFonts.anekDevanagari(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Enter your mobile number to continue",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.anekDevanagari(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 25),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "MOBILE NUMBER",
                                style: GoogleFonts.anekDevanagari(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),

                            Row(
                              children: [
                                Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50.withValues(
                                      alpha: 0.8,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _isPhoneValid
                                          ? Colors.black12
                                          : AppColors.error,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "🇮🇳 +91",
                                    style: GoogleFonts.anekDevanagari(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _isPhoneValid
                                            ? Colors.black12
                                            : AppColors.error,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      onChanged: (val) {
                                        if (!_isPhoneValid)
                                          setState(() => _isPhoneValid = true);
                                      },
                                      style: GoogleFonts.anekDevanagari(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        letterSpacing: 1.0,
                                      ),
                                      decoration: InputDecoration(
                                        counterText: "",
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 11,
                                            ),
                                        hintText: "00000 00000",
                                        hintStyle: GoogleFonts.anekDevanagari(
                                          color: Colors.black12,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            if (!_isPhoneValid)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 4),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    "Please enter a valid 10-digit number",
                                    style: GoogleFonts.anekDevanagari(
                                      color: AppColors.error,
                                      fontSize: 13.3,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                            if (authController.errorMessage != null &&
                                _isPhoneValid)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 14,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        authController.errorMessage!,
                                        style: GoogleFonts.anekDevanagari(
                                          color: AppColors.error,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 25),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: authController.isLoading
                                    ? null
                                    : () {
                                        final phone = _phoneController.text
                                            .trim();
                                        if (phone.length == 10) {
                                          setState(() => _isPhoneValid = true);
                                          authController.loginWithPhone(
                                            "+91$phone",
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => OtpScreen(
                                                  mobileNumber: "+91$phone",
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          setState(() => _isPhoneValid = false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: authController.isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        "GET OTP",
                                        style: GoogleFonts.anekDevanagari(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: keyboardHeight * 0.9),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcons() {
    const Color iconColor = Color(0xFFFF9641);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.youtube),
          color: iconColor,
          iconSize: 25,
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.facebook),
          color: iconColor,
          iconSize: 25,
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.instagram),
          color: iconColor,
          iconSize: 25,
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.xTwitter),
          color: iconColor,
          iconSize: 25,
          onPressed: () {},
        ),
      ],
    );
  }
}
