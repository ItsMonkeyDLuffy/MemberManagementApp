import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/dharma_app_bar.dart';
import '../../../../core/enums/app_bar_type.dart';
import '../../../../core/widgets/gradient_background.dart';

// We will create this final screen next
import 'payment_screen.dart';

class BeneficiaryScreen extends StatefulWidget {
  const BeneficiaryScreen({super.key});

  @override
  State<BeneficiaryScreen> createState() => _BeneficiaryScreenState();
}

class _BeneficiaryScreenState extends State<BeneficiaryScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();

  String _selectedGender = 'Male'; // Default selection

  // Date Picker Logic
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010), // Default to younger/child
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE89956), // Matching Orange
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
          // LAYER 1: STATIC BACKGROUND
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

                  // Footer
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

                      // GLASS CARD
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
                                  "Step 3 of 4: Beneficiary",
                                  style: GoogleFonts.anekDevanagari(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 2. PROGRESS BAR (3 Active)
                              Row(
                                children: [
                                  _buildProgressPill(isActive: true),
                                  const SizedBox(width: 8),
                                  _buildProgressPill(isActive: true),
                                  const SizedBox(width: 8),
                                  _buildProgressPill(isActive: true),
                                  const SizedBox(width: 8),
                                  _buildProgressPill(isActive: false),
                                ],
                              ),
                              const SizedBox(height: 30),

                              // 3. FORM FIELDS

                              // NAME
                              _buildLabel("Name"),
                              _buildTextField(
                                controller: _nameController,
                                hint: "Name",
                              ),
                              const SizedBox(height: 16),

                              // DOB
                              _buildLabel("Date of Birth"),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: _buildTextField(
                                    controller: _dobController,
                                    hint: "Date of Birth",
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // GENDER
                              _buildLabel("Gender"),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildRadioOption("Male"),
                                  const SizedBox(width: 20),
                                  _buildRadioOption("Female"),
                                  const SizedBox(width: 20),
                                  _buildRadioOption("Others"),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // AADHAR
                              _buildLabel("Aadhar Number"),
                              _buildTextField(
                                controller: _aadharController,
                                hint: "Aadhar Number",
                                keyboardType: TextInputType.number,
                                suffixIcon: Icons.camera_alt_outlined,
                              ),

                              const SizedBox(height: 15),

                              // ADD MEMBER BUTTON
                              Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    // Logic to add another beneficiary form
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Add Member feature coming soon!",
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    color: Color(0xFFE89956),
                                    size: 18,
                                  ),
                                  label: Text(
                                    "Add Member",
                                    style: GoogleFonts.roboto(
                                      color: const Color(0xFFE89956),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              // NEXT BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // Navigate to Step 4 (Payment)
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const PaymentScreen(),
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
                                    "NEXT: PAYMENT",
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

  // ================= Helpers =================

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
    IconData? suffixIcon,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.roboto(fontSize: 15, color: Colors.black87),
        validator: (val) => val == null || val.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.roboto(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ), // Centered
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.grey.shade500, size: 20)
              : null,
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    bool isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Row(
        children: [
          Container(
            height: 18,
            width: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFE89956)
                    : Colors.grey.shade500,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE89956),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.black87),
          ),
        ],
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
    return Row(
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
    );
  }
}
