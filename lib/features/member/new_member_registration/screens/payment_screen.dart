import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // ✅ Added for Repo access
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Added for UID

import '../../../../core/constants/colors.dart';

// ✅ Routes & Repo
import 'package:member_management_app/routes/app_routes.dart';
import '../../../../data/repositories/interfaces/member_repository.dart';

// ✅ Shared Widgets
import 'widgets_registration/registration_wrapper.dart';
import 'widgets_registration/registration_card.dart';
import 'widgets_registration/form_components.dart';

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

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);

    try {
      // 1. SIMULATE PAYMENT GATEWAY
      // In a real app, you would await Razorpay/Stripe here.
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // 2. UPDATE FIRESTORE STATUS
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // We update status to 'PENDING_APPROVAL' (or 'ACTIVE' depending on your logic)
      // We also mark payment as done.
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

      // 3. CLEAR LOCAL DATA
      _data.clearData();

      // 4. NAVIGATE TO DASHBOARD
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Successful! Welcome Aboard."),
            backgroundColor: Colors.green,
          ),
        );

        // Clear stack and go to Home
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.memberHome, // Ensure this route exists in your AppRoutes
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment Failed: $e"),
            backgroundColor: AppColors.error,
          ),
        );
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
    return RegistrationWrapper(
      // Standard Back: Pops to Step 3 (Beneficiaries)
      onBack: () => Navigator.pop(context),

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
                    const TextSpan(text: "By clicking Pay, you agree to our "),
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
    );
  }
}
