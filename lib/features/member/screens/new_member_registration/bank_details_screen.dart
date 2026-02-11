import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/dharma_app_bar.dart';
import '../../../../core/enums/app_bar_type.dart';
import '../../../../core/widgets/gradient_background.dart';

// We will create this file next
import 'package:member_management_app/features/member/screens/new_member_registration/benificiary_screen.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _accountNoController = TextEditingController();
  final TextEditingController _confirmAccountNoController =
      TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 📏 Measurements
    final double topBarrierHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: DharmaAppBar(
        title: "Registration",
        type: DharmaAppBarType.custom,
        onPrimaryAction: () => Navigator.pop(context),
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

                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: _buildFooter(),
                  ),
                ],
              ),
            ),
          ),

          // ============================================
          // LAYER 2: SCROLLABLE FORM
          // ============================================
          Column(
            children: [
              SizedBox(height: topBarrierHeight),

              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // ============================================
                      // GLASS CARD
                      // ============================================
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.85),
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. HEADER
                              Center(
                                child: Text(
                                  "MEMBER REGISTRATION",
                                  style: GoogleFonts.anekDevanagari(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFE89956),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  "Step 2 of 4: Bank Details",
                                  style: GoogleFonts.anekDevanagari(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 2. PROGRESS BAR (Steps 1 & 2 Active)
                              Row(
                                children: [
                                  _buildProgressPill(
                                    isActive: true,
                                  ), // Step 1 Done
                                  const SizedBox(width: 8),
                                  _buildProgressPill(
                                    isActive: true,
                                  ), // Step 2 Active
                                  const SizedBox(width: 8),
                                  _buildProgressPill(isActive: false),
                                  const SizedBox(width: 8),
                                  _buildProgressPill(isActive: false),
                                ],
                              ),
                              const SizedBox(height: 30),

                              // 3. FORM FIELDS

                              // --- ACCOUNT NUMBER ---
                              _buildLabel("Account Number"),
                              _buildTextField(
                                controller: _accountNoController,
                                hint: "Account Number",
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),

                              // --- CONFIRM ACCOUNT NUMBER ---
                              _buildLabel("Confirm Account Number"),
                              _buildTextField(
                                controller: _confirmAccountNoController,
                                hint: "Account Number",
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val != _accountNoController.text) {
                                    return "Account numbers do not match";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // --- IFSC CODE ---
                              _buildLabel("IFSC Code"),
                              _buildTextField(
                                controller: _ifscController,
                                hint: "IFSC Code",
                                textCapitalization:
                                    TextCapitalization.characters,
                              ),
                              const SizedBox(height: 16),

                              // --- BANK NAME ---
                              _buildLabel("Bank Name"),
                              _buildTextField(
                                controller: _bankNameController,
                                hint: "Bank Name",
                              ),

                              const SizedBox(height: 30),

                              // --- NEXT BUTTON ---
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // Navigate to Step 3
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const BeneficiaryScreen(),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE89956),
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
                    ],
                  ),
                ),
              ),

              SizedBox(height: keyboardHeight),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // WIDGET HELPERS
  // ============================================

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: GoogleFonts.roboto(fontSize: 15, color: Colors.black87),
        validator:
            validator ??
            (val) => val == null || val.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.roboto(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          // Removes default error text space to keep UI compact,
          // assumes you handle errors visually or are okay with standard expansion
        ),
      ),
    );
  }

  Widget _buildProgressPill({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE89956) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    const Color iconColor = Color(0xFFE89956);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.youtube),
              color: iconColor,
              iconSize: 20,
              onPressed: () {},
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.facebook),
              color: iconColor,
              iconSize: 20,
              onPressed: () {},
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.xTwitter),
              color: iconColor,
              iconSize: 20,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
