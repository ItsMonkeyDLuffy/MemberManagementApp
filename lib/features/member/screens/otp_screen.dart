import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/services.dart';

import '../../auth/logic/auth_controller.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/dharma_app_bar.dart';
import '../../../core/enums/app_bar_type.dart';
import '../../../core/widgets/gradient_background.dart';

import '../../../../core/utils/validators.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  const OtpScreen({super.key, required this.mobileNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  String? _otpError;
  bool _otpResentSuccess = false; // ✅ ADDED: For the success message

  Timer? _timer;
  int _start = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _start = 30;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _canResend = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _handleNavigation(String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  void _submitOtp(AuthController authController, String pin) {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    final validationError = Validators.validateOTP(pin);

    if (validationError != null) {
      setState(() => _otpError = validationError);
      return;
    }

    setState(() {
      _otpError = null;
      _otpResentSuccess = false; // Hide success msg when they try to login
    });
    authController.verifyOtp(pin, _handleNavigation);
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double topBarrierHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight - 50;

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
        border: Border.all(
          color: _otpError == null ? Colors.black12 : AppColors.error,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        authController.clearError();
        Navigator.pop(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,

        appBar: DharmaAppBar(
          type: DharmaAppBarType.custom,
          onPrimaryAction: () {
            authController.clearError();
            Navigator.pop(context);
          },
        ),

        body: Stack(
          children: [
            Positioned.fill(
              child: GradientBackground(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
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

            Column(
              children: [
                SizedBox(height: topBarrierHeight),

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
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_outline,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 18),

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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            Pinput(
                              length: 6,
                              controller: _otpController,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              autofillHints: const [AutofillHints.oneTimeCode],
                              showCursor: true,
                              pinputAutovalidateMode:
                                  PinputAutovalidateMode.onSubmit,
                              onChanged: (val) {
                                if (_otpError != null) {
                                  setState(() => _otpError = null);
                                }
                                if (authController.errorMessage != null) {
                                  authController.clearError();
                                }
                                if (_otpResentSuccess) {
                                  setState(() => _otpResentSuccess = false);
                                }
                              },
                              onCompleted: (pin) =>
                                  _submitOtp(authController, pin),
                            ),

                            if (_otpError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  _otpError!,
                                  style: GoogleFonts.anekDevanagari(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

                            // ✅ SUCCESS MESSAGE: Shows quietly after resending
                            if (_otpResentSuccess)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  "OTP Resent Successfully",
                                  style: GoogleFonts.anekDevanagari(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

                            if (authController.errorMessage != null &&
                                _otpError == null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  authController.errorMessage!,
                                  style: GoogleFonts.anekDevanagari(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: authController.isLoading
                                    ? null
                                    : () => _submitOtp(
                                        authController,
                                        _otpController.text.trim(),
                                      ),
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
                              onTap: _canResend
                                  ? () {
                                      setState(() {
                                        _otpError = null;
                                        _otpController.clear();
                                      });
                                      authController.clearError();

                                      authController.loginWithPhone(
                                        widget.mobileNumber,
                                        () {
                                          setState(
                                            () => _otpResentSuccess = true,
                                          );
                                          _startTimer(); // ✅ Restarts timer ONLY after success
                                        },
                                      );
                                    }
                                  : null,
                              child: Text(
                                _canResend
                                    ? "Didn't receive code? Resend"
                                    : "Resend code in $_start"
                                          "s",
                                style: GoogleFonts.anekDevanagari(
                                  color: _canResend
                                      ? AppColors.textSecondary
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  decoration: _canResend
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: keyboardHeight * 0.55),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
