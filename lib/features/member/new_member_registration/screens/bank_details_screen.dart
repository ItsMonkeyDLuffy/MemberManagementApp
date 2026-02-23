import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // <-- ADDED: Required for SystemChannels

// ✅ Import Routes & Repo
import 'package:member_management_app/routes/app_routes.dart';
import '../../../../data/repositories/interfaces/member_repository.dart';

import '../../../../core/constants/colors.dart';

// ✅ Shared Widgets
import '../widgets/registration_wrapper.dart';
import '../widgets/registration_card.dart';
import '../widgets/form_components.dart';

// ✅ Logic
import '../registration_data_manager.dart';

// ✅ ADDED: Import your new Validators class here.
// (Update this path to wherever your validators.dart file is saved!)
import '../../../../core/utils/validators.dart';

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

  bool _isSaving = false;
  String? _submitError; // ✅ ADDED: For quiet server errors

  @override
  void initState() {
    super.initState();
    // 🔄 AUTO-FILL: Load Saved Data (from Singleton)
    _acNoCtrl = TextEditingController(text: _data.accountNo);
    // If confirm is empty but account isn't, pre-fill confirm too for convenience
    _confAcNoCtrl = TextEditingController(
      text: _data.confirmAccountNo.isNotEmpty
          ? _data.confirmAccountNo
          : _data.accountNo,
    );
    _ifscCtrl = TextEditingController(text: _data.ifsc);
    _bankNameCtrl = TextEditingController(text: _data.bankName);
  }

  @override
  void dispose() {
    // Sync back to singleton on exit
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

  // ==========================================
  // 💾 LOGIC: SAVE DRAFT & NEXT
  // ==========================================
  Future<void> _onNextPressed() async {
    // <-- ADDED: Strongest way to kill keyboard and clear focus memory
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    setState(() {
      _submitError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // 1. Sync to Singleton
      _data.accountNo = _acNoCtrl.text.trim();
      _data.confirmAccountNo = _confAcNoCtrl.text.trim();
      _data.ifsc = _ifscCtrl.text.trim().toUpperCase();
      _data.bankName = _bankNameCtrl.text.trim();

      // 2. Prepare Payload
      final draftData = {
        'current_step': 3, // Move to Beneficiary Step next time
        'bank_details': {
          'account_no': _data.accountNo,
          'ifsc': _data.ifsc,
          'bank_name': _data.bankName,
        },
      };

      // 3. Save to Firestore
      await context.read<MemberRepository>().saveMemberDraft(
        uid: uid,
        data: draftData,
      );

      // 4. Navigate
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pushNamed(context, AppRoutes.registrationStep3);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _submitError =
              "Failed to save bank details. Please check connection.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double bottomPadding = keyboardHeight > 70
        ? keyboardHeight - 70
        : 20.0;

    // ✅ RESTORED: Your exact WillPopScope logic!
    return WillPopScope(
      onWillPop: () async {
        // <-- ADDED: Kill keyboard before going back via hardware button
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        Navigator.pop(context); // Go back one step
        return false; // Prevent app exit
      },
      child: RegistrationWrapper(
        // ✅ FIXED: Explicitly pop context on App Bar back arrow
        onBack: () {
          // <-- ADDED: Kill keyboard before going back via UI arrow
          FocusManager.instance.primaryFocus?.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.pop(context);
        },
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
                    // ✅ FIXED: Removed autovalidateMode so errors ONLY show when "Next" is pressed
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. ACCOUNT NUMBER
                        const RegistrationLabel("Account Number"),
                        RegistrationTextField(
                          controller: _acNoCtrl,
                          hint: "Enter Account Number",
                          keyboardType: TextInputType.number,
                          maxLength: 18,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          // ✅ FIXED: Replaced massive mistaken IFSC code block with correct Account validator
                          validator: Validators.validateAccountNo,
                        ),
                        const SizedBox(height: 16),

                        // 2. CONFIRM ACCOUNT NUMBER
                        const RegistrationLabel("Confirm Account Number"),
                        RegistrationTextField(
                          controller: _confAcNoCtrl,
                          hint: "Re-enter Account Number",
                          keyboardType: TextInputType.number,
                          maxLength: 18,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (val) =>
                              Validators.validateConfirmAccountNo(
                                val,
                                _acNoCtrl.text,
                              ),
                        ),
                        const SizedBox(height: 16),

                        // 3. IFSC CODE
                        const RegistrationLabel("IFSC Code"),
                        RegistrationTextField(
                          controller: _ifscCtrl,
                          hint: "e.g. SBIN0001234",
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 11,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]'),
                            ),
                          ],
                          validator: Validators.validateIFSC,
                        ),
                        const SizedBox(height: 16),

                        // 4. BANK NAME
                        const RegistrationLabel("Bank Name"),
                        RegistrationTextField(
                          controller: _bankNameCtrl,
                          hint: "Enter Bank Name",
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]'),
                            ),
                          ],
                          validator: (val) =>
                              Validators.validateRequired(val, "Bank Name"),
                        ),

                        const SizedBox(height: 30),

                        // ✅ Quiet Inline Error for Server Failures
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

                        // ✅ NEXT BUTTON (Updated Logic)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _onNextPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
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
      ),
    );
  }
}
