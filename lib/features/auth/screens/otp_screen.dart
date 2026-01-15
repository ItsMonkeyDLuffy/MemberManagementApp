import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/auth_controller.dart';
import '../../../core/utils/validators.dart';
import '../../member/screens/family_list_screen.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "Code sent to ${widget.mobileNumber}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // OTP Input Field
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                hintText: "------",
                border: OutlineInputBorder(),
                counterText: "",
              ),
            ),

            // Error Message Display
            if (authController.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  authController.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 30),

            // Verify Button
            authController.isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final otp = _otpController.text.trim();
                        if (Validators.validateOTP(otp) == null) {
                          authController.verifyOtp(otp, () {
                            // 1. Show Success Message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Login Successful!"),
                              ),
                            );

                            // 2. NAVIGATE to the next screen (Fix is here)
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FamilyListScreen(),
                              ),
                              (route) =>
                                  false, // This removes the "Back" arrow so user can't go back to Login
                            );
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Invalid OTP format")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "VERIFY",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
