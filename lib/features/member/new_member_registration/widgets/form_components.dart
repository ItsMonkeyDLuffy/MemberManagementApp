import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ ADDED: Required for TextInputFormatter
import 'package:google_fonts/google_fonts.dart';
import '/core/constants/colors.dart';

// --- LABEL ---
class RegistrationLabel extends StatelessWidget {
  final String text;
  const RegistrationLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// --- TEXT FIELD ---
class RegistrationTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool readOnly;
  final FocusNode? focusNode;
  final bool isSuffixSuccess;

  // ✅ NEW PARAMETERS ADDED
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters; // ✅ ADDED
  final int? maxLength; // ✅ ADDED

  const RegistrationTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.suffixIcon,
    this.onSuffixTap,
    this.readOnly = false,
    this.focusNode,
    this.isSuffixSuccess = false,
    // ✅ Initialize new params
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters, // ✅ ADDED
    this.maxLength, // ✅ ADDED
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: Colors.transparent,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        readOnly: readOnly,
        // ✅ Apply Capitalization
        textCapitalization: textCapitalization,
        // ✅ Apply Formatters and Length
        inputFormatters: inputFormatters, // ✅ ADDED
        maxLength: maxLength, // ✅ ADDED

        style: GoogleFonts.roboto(fontSize: 15, color: AppColors.textPrimary),

        // ✅ Use custom validator if provided, else fall back to default logic
        validator:
            validator ??
            (val) {
              if (hint.contains("Optional")) return null;
              return (val == null || val.trim().isEmpty) ? "Required" : null;
            },

        decoration: InputDecoration(
          hintText: hint,
          counterText: "", // ✅ Hides the character counter for a cleaner look
          hintStyle: GoogleFonts.roboto(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),

          // ✅ Internal Error Styling (Quiet Red Lines)
          errorStyle: GoogleFonts.roboto(color: Colors.red, fontSize: 10.5),

          suffixIcon: suffixIcon != null
              ? IconButton(
                  onPressed: onSuffixTap,
                  icon: Icon(
                    suffixIcon,
                    color: isSuffixSuccess
                        ? Colors.green
                        : AppColors.textSecondary,
                    size: 22,
                  ),
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.primary),
          ),

          // ✅ Red Borders for Error State
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// --- PROGRESS PILLS ---
class ProgressPills extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const ProgressPills({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        bool isActive = index < currentStep;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }
}
