import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart'; // ✅ Added for Repository access
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Added for UID

import 'package:member_management_app/routes/app_routes.dart';
import '../../../../data/repositories/interfaces/member_repository.dart'; // ✅ Added Repo Interface

import '../../../../core/constants/colors.dart';
import 'widgets_registration/registration_wrapper.dart';
import 'widgets_registration/registration_card.dart';
import 'widgets_registration/form_components.dart';
import 'widgets_registration/document_thumbnail.dart';
import 'widgets_registration/image_picker_utils.dart';
import '../registration_data_manager.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _data = RegistrationDataManager(); // Singleton

  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _aadharController;

  final FocusNode _aadharFocusNode = FocusNode();
  final FocusNode _dummyFocusNode = FocusNode();

  bool _isSaving = false; // ✅ Loader State

  @override
  void initState() {
    super.initState();
    // 1. Auto-fill from Singleton (Loaded from Firestore or Memory)
    _nameController = TextEditingController(text: _data.name);
    _dobController = TextEditingController(text: _data.dob);
    _aadharController = TextEditingController(text: _data.aadharNumber);

    // Ensure gender is set (Default 'Male' is handled in Singleton)
    if (_data.gender.isEmpty) _data.gender = 'Male';

    _retrieveLostData();
  }

  Future<void> _retrieveLostData() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) return;
      final file = response.file;
      if (file != null) {
        setState(() {
          if (_data.aadharFront == null) {
            _data.aadharFront = File(file.path);
          } else {
            _data.aadharBack = File(file.path);
          }
        });
      }
    } catch (e) {
      debugPrint("Error recovering lost data: $e");
    }
  }

  @override
  void dispose() {
    // Sync text back to singleton just in case
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
  // 💾 LOGIC: SAVE & NEXT
  // ==========================================
  Future<void> _onNextPressed() async {
    if (!_formKey.currentState!.validate()) return;

    // Check for EITHER local File OR existing Cloud URL
    bool hasFront = _data.aadharFront != null || _data.aadharFrontUrl != null;
    bool hasBack = _data.aadharBack != null || _data.aadharBackUrl != null;

    if (!hasFront || !hasBack) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload BOTH Front and Back of Aadhar Card"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // 1. Sync Text Data to Singleton
      _data.name = _nameController.text.trim();
      _data.dob = _dobController.text.trim();
      _data.aadharNumber = _aadharController.text.trim();
      // _data.gender is updated via Radio buttons directly

      // 2. Prepare Payload (Save Draft)
      // We save text details + URLs (if they exist).
      // New local files are NOT uploaded here (typically done at final submit or background).
      final draftData = {
        'current_step': 2, // Move to Bank Step next time
        'personal_details': {
          'name': _data.name,
          'dob': _data.dob,
          'gender': _data.gender,
          'aadhaar_no': _data.aadharNumber,
          'aadhaar_front_url': _data.aadharFrontUrl,
          'aadhaar_back_url': _data.aadharBackUrl,
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
        Navigator.pushNamed(context, AppRoutes.registrationStep2);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving draft: $e")));
      }
    }
  }

  Future<void> _handleExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              ),
            ),
          ],
        ),
        content: Text(
          "Your progress will be lost if you haven't clicked Next. Are you sure?",
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(
                    "Yes, Exit",
                    style: GoogleFonts.roboto(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    "No, Stay",
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      if (!mounted) return;
      _data.clearData();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

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
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
        _data.dob = _dobController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double bottomPadding = keyboardHeight > 70
        ? keyboardHeight - 70
        : 20.0;

    // ✅ Logic Update: Complete if (File exists OR Url exists)
    bool isAadharFrontDone =
        _data.aadharFront != null || _data.aadharFrontUrl != null;
    bool isAadharBackDone =
        _data.aadharBack != null || _data.aadharBackUrl != null;
    bool isAadharComplete = isAadharFrontDone && isAadharBackDone;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleExit();
      },
      child: RegistrationWrapper(
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
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Step 1 of 4: Personal Info",
                      style: GoogleFonts.anekDevanagari(
                        fontSize: 14,
                        color: AppColors.textPrimary,
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
                            _buildRadioOption("Other"),
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
                          onSuffixTap: () {
                            // Only prompt if not complete
                            if (_data.aadharFront == null) {
                              ImagePickerUtils.showSourceSelection(
                                context,
                                onImagePicked: (f) =>
                                    setState(() => _data.aadharFront = f),
                              );
                            }
                          },
                        ),

                        // Show thumbnails if File OR URL exists
                        if (isAadharFrontDone || isAadharBackDone)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DocumentThumbnail(
                                    title: "Front Side",
                                    file: _data.aadharFront,
                                    // If we have a URL but no File, this widget might need an update
                                    // For now, if file is null, we assume the user might want to re-upload
                                    // or we show a placeholder.
                                    onDelete: () => setState(() {
                                      _data.aadharFront = null;
                                      _data.aadharFrontUrl = null;
                                    }),
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
                                    onDelete: () => setState(() {
                                      _data.aadharBack = null;
                                      _data.aadharBackUrl = null;
                                    }),
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

                        // ✅ NEXT BUTTON (Updated)
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
                                    "NEXT: BANK DETAILS",
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
            ),
          ),
        ],
      ),
    );
  }
}
