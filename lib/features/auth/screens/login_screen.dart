import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/auth_controller.dart';
import 'package:member_management_app/features/auth/screens/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Member Login",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Mobile Number",
                hintText: "9876543210",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            if (authController.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  authController.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            authController.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      final phone = _phoneController.text.trim();

                      // 1. Basic Validation
                      if (phone.length == 10) {
                        // 2. Format for Firebase (+91 for India)
                        String formattedPhone = "+91$phone";

                        // 3. Call Controller
                        authController.loginWithPhone(formattedPhone, () {
                          // 4. Navigate on Success (This is the callback)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OtpScreen(mobileNumber: formattedPhone),
                            ),
                          );
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please enter a valid 10-digit number",
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("Send OTP"),
                  ),
          ],
        ),
      ),
    );
  }
}
