import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';

// ✅ Shared Widgets
import 'widgets_registration/registration_wrapper.dart';
import 'widgets_registration/registration_card.dart';
import 'widgets_registration/form_components.dart';
import 'widgets_registration/document_thumbnail.dart';
import 'widgets_registration/image_picker_utils.dart';

// ✅ Logic & Screens
import 'registration_data_manager.dart';
import 'bank_details_screen.dart';
import '../member_login_screen.dart'; // 👈 The "Home/Login" Screen

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _data = RegistrationDataManager();

  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _aadharController;

  final FocusNode _aadharFocusNode = FocusNode();
  final FocusNode _dummyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _data.name);
    _dobController = TextEditingController(text: _data.dob);
    _aadharController = TextEditingController(text: _data.aadharNumber);
  }

  @override
  void dispose() {
    // Save data temporarily in case they come back (if staying in flow)
    _data.name = _nameController.text;
    _data.dob = _dobController.text;
    _data.aadharNumber = _aadharController.text;

    _nameController.dispose();
    _dobController.dispose();
    _aadharController.dispose();
    _aadharFocusNode.dispose();
    _dummyFocusNode.dispose();
    super.dispose();
  }

  // ==========================================
  // 🛑 UNIFIED EXIT LOGIC (Crash Fixed)
  // ==========================================
  Future<void> _handleExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

        // 1. HEADER WITH ICON
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Exit Registration?",
              textAlign: TextAlign.center,
              style: GoogleFonts.anekDevanagari(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ],
        ),

        // 2. CONTENT
        content: Text(
          "Going back will delete your current progress. Are you sure you want to exit?",
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 15,
            color: AppColors.textSecondary, // or Colors.grey[700]
            height: 1.5,
          ),
        ),

        // 3. ACTIONS
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              // DESTRUCTIVE ACTION (EXIT)
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Yes, Exit",
                    style: GoogleFonts.roboto(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // PRIMARY ACTION (STAY)
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "No, Stay",
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // 2. Handle Navigation AFTER the dialog is fully closed
    if (shouldExit == true) {
      if (!mounted) return;
      _data.clearData();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MemberLoginScreen()),
        (route) => false,
      );
    }
  }

  // ==========================================
  // 📅 DATE PICKER
  // ==========================================
  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(_dummyFocusNode);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    FocusScope.of(context).requestFocus(_dummyFocusNode);
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
        _data.dob = _dobController.text;
      });
    }
  }

  // ==========================================
  // 📸 UPLOAD LOGIC
  // ==========================================
  void _handleAadharUploadClick() {
    if (_data.aadharFront == null) {
      ImagePickerUtils.showSourceSelection(
        context,
        onImagePicked: (f) => setState(() => _data.aadharFront = f),
      );
    } else if (_data.aadharBack == null) {
      ImagePickerUtils.showSourceSelection(
        context,
        onImagePicked: (f) => setState(() => _data.aadharBack = f),
      );
    }
  }

  // ==========================================
  // 🎨 BUILD UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double bottomPadding = keyboardHeight > 70
        ? keyboardHeight - 70
        : 20.0;
    bool isAadharComplete =
        _data.aadharFront != null && _data.aadharBack != null;

    // ✅ KEY FIX: PopScope with canPop: false
    // This intercepts the System Back Gesture (Swipe/Button)
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleExit(); // Trigger our custom dialog logic
      },
      child: RegistrationWrapper(
        // ✅ KEY FIX: Override App Bar Back Button
        // Ensure the back arrow triggers the same dialog logic
        onBack: _handleExit,

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
                      "Step 1 of 4: Personal Info",
                      style: GoogleFonts.anekDevanagari(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const ProgressPills(totalSteps: 4, currentStep: 1),
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
                        const RegistrationLabel("Name"),
                        RegistrationTextField(
                          controller: _nameController,
                          hint: "Full Name",
                        ),
                        const SizedBox(height: 16),

                        const RegistrationLabel("Date of Birth"),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: RegistrationTextField(
                              controller: _dobController,
                              hint: "Select Date",
                              readOnly: true,
                              suffixIcon: Icons.calendar_today_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const RegistrationLabel("Gender"),
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

                        const RegistrationLabel("Aadhar Number"),
                        RegistrationTextField(
                          controller: _aadharController,
                          hint: "12 Digit Number",
                          keyboardType: TextInputType.number,
                          focusNode: _aadharFocusNode,
                          suffixIcon: isAadharComplete
                              ? Icons.check_circle
                              : Icons.camera_alt_outlined,
                          isSuffixSuccess: isAadharComplete,
                          onSuffixTap: _handleAadharUploadClick,
                        ),

                        if (_data.aadharFront != null ||
                            _data.aadharBack != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DocumentThumbnail(
                                    title: "Front Side",
                                    file: _data.aadharFront,
                                    onDelete: () => setState(
                                      () => _data.aadharFront = null,
                                    ),
                                    onTap: () =>
                                        ImagePickerUtils.showSourceSelection(
                                          context,
                                          onImagePicked: (f) => setState(
                                            () => _data.aadharFront = f,
                                          ),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DocumentThumbnail(
                                    title: "Back Side",
                                    file: _data.aadharBack,
                                    onDelete: () =>
                                        setState(() => _data.aadharBack = null),
                                    onTap: () =>
                                        ImagePickerUtils.showSourceSelection(
                                          context,
                                          onImagePicked: (f) => setState(
                                            () => _data.aadharBack = f,
                                          ),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (_data.aadharFront == null ||
                                    _data.aadharBack == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please upload BOTH Front and Back of Aadhar Card",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BankDetailsScreen(),
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
                              "NEXT: BANK DETAILS",
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

  Widget _buildRadioOption(String value) {
    bool isSelected = _data.gender == value;
    return GestureDetector(
      onTap: () => setState(() => _data.gender = value),
      child: Row(
        children: [
          Container(
            height: 18,
            width: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
