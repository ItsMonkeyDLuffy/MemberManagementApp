import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../../auth/logic/auth_controller.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/dharma_app_bar.dart';
import '../../../core/enums/app_bar_type.dart';
import '../../../core/widgets/gradient_background.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  const OtpScreen({super.key, required this.mobileNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // 📏 Measurements
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double topBarrierHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight - 50;

    // Smaller pin theme for more compact look
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: GoogleFonts.anekDevanagari(
        fontSize: 21,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 3),
            blurRadius: 5,
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: DharmaAppBar(
        type: DharmaAppBarType.custom,
        onPrimaryAction: () => Navigator.pop(context),
      ),

      body: Stack(
        children: [
          // ============================================
          // LAYER 1: BACKGROUND (Gradient + Flag)
          // ============================================
          Positioned.fill(
            child: GradientBackground(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    // Aligned loosely with the top barrier
                    top: topBarrierHeight + 65,
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

          // ============================================
          // LAYER 2: MANUAL LAYOUT COLUMN
          // ============================================
          Column(
            children: [
              // 🧱 TOP BARRIER
              SizedBox(height: topBarrierHeight),

              // 🎯 CONTENT AREA
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 22,
                      ),
                      decoration: BoxDecoration(
                        // ✅ MATCH LOGIN SCREEN: Transparent White
                        color: AppColors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                        // ✅ MATCH LOGIN SCREEN: Border
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Smaller icon container
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Smaller title
                          Text(
                            "VERIFICATION",
                            style: GoogleFonts.anekDevanagari(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Smaller text
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.anekDevanagari(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                  text: "Enter the code sent to\n",
                                ),
                                TextSpan(
                                  text: widget.mobileNumber,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          // Pinput
                          Pinput(
                            length: 6,
                            controller: _otpController,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            showCursor: true,
                            pinputAutovalidateMode:
                                PinputAutovalidateMode.onSubmit,
                            onCompleted: (pin) {
                              authController.verifyOtp(pin, () {});
                            },
                          ),

                          if (authController.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                authController.errorMessage!,
                                style: GoogleFonts.anekDevanagari(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),
                          // Smaller button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: authController.isLoading
                                  ? null
                                  : () {
                                      authController.verifyOtp(
                                        _otpController.text.trim(),
                                        () {},
                                      );
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
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      "VERIFY & LOGIN",
                                      style: GoogleFonts.anekDevanagari(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              "Didn't receive code? Resend",
                              style: GoogleFonts.anekDevanagari(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 🎹 KEYBOARD PUSHER
              SizedBox(height: keyboardHeight * 0.55),
            ],
          ),
        ],
      ),
    );
  }
}
