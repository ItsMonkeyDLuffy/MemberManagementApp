import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';

// ✅ Shared Widgets
import 'widgets_registration/registration_wrapper.dart';
import 'widgets_registration/registration_card.dart';
import 'widgets_registration/form_components.dart';

// ✅ Logic
import 'registration_data_manager.dart';
import 'package:member_management_app/features/member/screens/new_member_registration/benificiary_screen.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _data = RegistrationDataManager(); // Singleton

  late TextEditingController _acNoCtrl;
  late TextEditingController _confAcNoCtrl;
  late TextEditingController _ifscCtrl;
  late TextEditingController _bankNameCtrl;

  @override
  void initState() {
    super.initState();
    // 🔄 LOAD SAVED DATA
    _acNoCtrl = TextEditingController(text: _data.accountNo);
    _confAcNoCtrl = TextEditingController(text: _data.confirmAccountNo);
    _ifscCtrl = TextEditingController(text: _data.ifsc);
    _bankNameCtrl = TextEditingController(text: _data.bankName);
  }

  @override
  void dispose() {
    // 💾 SAVE DATA
    _data.accountNo = _acNoCtrl.text;
    _data.confirmAccountNo = _confAcNoCtrl.text;
    _data.ifsc = _ifscCtrl.text;
    _data.bankName = _bankNameCtrl.text;

    _acNoCtrl.dispose();
    _confAcNoCtrl.dispose();
    _ifscCtrl.dispose();
    _bankNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double bottomPadding = keyboardHeight > 70
        ? keyboardHeight - 70
        : 20.0;

    return RegistrationWrapper(
      // Standard Back Navigation (Goes back to Step 1)
      onBack: () => Navigator.pop(context),

      child: RegistrationCard(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Column(
                children: [
                  Text(
                    "MEMBER REGISTRATION",
                    style: GoogleFonts.anekDevanagari(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Step 2 of 4: Bank Details",
                    style: GoogleFonts.anekDevanagari(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const ProgressPills(totalSteps: 4, currentStep: 2),
                ],
              ),
            ),

            // --- FORM ---
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. ACCOUNT NUMBER
                      const RegistrationLabel("Account Number"),
                      RegistrationTextField(
                        controller: _acNoCtrl,
                        hint: "Enter Account Number",
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // 2. CONFIRM ACCOUNT NUMBER
                      const RegistrationLabel("Confirm Account Number"),
                      RegistrationTextField(
                        controller: _confAcNoCtrl,
                        hint: "Re-enter Account Number",
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Required";
                          if (val != _acNoCtrl.text)
                            return "Account numbers do not match";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3. IFSC CODE
                      const RegistrationLabel("IFSC Code"),
                      RegistrationTextField(
                        controller: _ifscCtrl,
                        hint: "Enter IFSC Code",
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),

                      // 4. BANK NAME
                      const RegistrationLabel("Bank Name"),
                      RegistrationTextField(
                        controller: _bankNameCtrl,
                        hint: "Enter Bank Name",
                        textCapitalization: TextCapitalization.words,
                      ),

                      const SizedBox(height: 30),

                      // NEXT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BeneficiaryScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            "NEXT: BENEFICIARY",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
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
          ],
        ),
      ),
    );
  }
}
