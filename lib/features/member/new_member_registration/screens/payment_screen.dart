import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // <-- ADDED: Required for SystemChannels

import '../../../../core/constants/colors.dart';

// ✅ Routes & Repo
import 'package:member_management_app/routes/app_routes.dart';
import '../../../../data/repositories/interfaces/member_repository.dart';

// ✅ Shared Widgets
import '../widgets/registration_wrapper.dart';
import '../widgets/registration_card.dart';
import '../widgets/form_components.dart';

// ✅ Logic
import '../registration_data_manager.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _data = RegistrationDataManager(); // ✅ Singleton Instance
  bool _isInfoConfirmed = false;
  bool _isProcessing = false; // ✅ Loading State

  String? _submitError; // ✅ ADDED: For quiet inline errors

  Future<void> _handlePayment() async {
    // <-- ADDED: Safety check to kill keyboard if it stayed open from Step 3
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    setState(() {
      _submitError = null;
      _isProcessing = true;
    });

    try {
      // 1. SIMULATE PAYMENT GATEWAY
      // In a real app, you would await Razorpay/Stripe here.
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // 2. UPDATE FIRESTORE STATUS
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // We update status to 'PENDING_APPROVAL' and mark step as 5 (Complete)
      await context.read<MemberRepository>().updateProfile(
        uid: uid,
        data: {
          'status': 'PENDING_APPROVAL', // Registration Complete!
          'payment_status': 'COMPLETED',
          'amount_paid': 499.00,
          'current_step': 5, // 5 = Done
          'submitted_at': DateTime.now(),
        },
      );

      // 3. CLEAR LOCAL DATA (Reset form for next time)
      _data.clearData();

      // 4. NAVIGATE TO HOME (Clear History)
      if (mounted) {
        // ✅ Kept the Green Success Snackbar because they are moving to the Home Screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Successful! Application Submitted."),
            backgroundColor: Colors.green,
          ),
        );

        // Clear stack and go to Member Home
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.memberHome,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          // ✅ FIXED: Replaced red snackbar with quiet inline error
          _submitError = "Payment Failed: Please try again.";
        });
      }
    }
  }

  void _openTermsAndConditions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Navigate to Terms & Conditions Page")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // <-- ADDED: Safety kill keyboard before going back
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        Navigator.pop(context); // Go back to Step 3
        return false; // Prevent App Exit
      },
      child: RegistrationWrapper(
        onBack: () {
          // <-- ADDED: Safety kill keyboard before going back
          FocusManager.instance.primaryFocus?.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.pop(context);
        },
        child: RegistrationCard(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
            child: Column(
              children: [
                // --- HEADER ---
                Text(
                  "MEMBER REGISTRATION",
                  style: GoogleFonts.anekDevanagari(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Step 4 of 4: Payment",
                  style: GoogleFonts.anekDevanagari(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),

                // ✅ SHARED PROGRESS PILLS
                const ProgressPills(totalSteps: 4, currentStep: 4),

                // --- FLEXIBLE MIDDLE SECTION ---
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 1. Payment Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.payment_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),

                      // 2. Info Text
                      Column(
                        children: [
                          Text(
                            "Complete Registration",
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "To become a verified member, a non-refundable registration fee is required.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),

                      // 3. Amount Display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Total Amount",
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "₹499.00",
                              style: GoogleFonts.roboto(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 4. Confirmation Checkbox
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isInfoConfirmed = !_isInfoConfirmed;
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _isInfoConfirmed,
                                activeColor: AppColors.primary,
                                side: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) => setState(
                                  () => _isInfoConfirmed = val ?? false,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "I confirm that all the information submitted above is true.",
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ Quiet Inline Error for Payment Failures
                if (_submitError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Center(
                      child: Text(
                        _submitError!,
                        style: GoogleFonts.roboto(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // --- BOTTOM BUTTON & TERMS ---
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (_isInfoConfirmed && !_isProcessing)
                        ? _handlePayment
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isInfoConfirmed
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: _isInfoConfirmed ? 2 : 0,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "PAY NOW",
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                // Terms Link
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.roboto(fontSize: 11, color: Colors.grey),
                    children: [
                      const TextSpan(
                        text: "By clicking Pay, you agree to our ",
                      ),
                      TextSpan(
                        text: "Terms & Conditions",
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _openTermsAndConditions,
                      ),
                      const TextSpan(text: "."),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
