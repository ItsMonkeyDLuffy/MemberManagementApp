import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'package:member_management_app/routes/app_routes.dart';
import '../../../../data/repositories/interfaces/member_repository.dart';

import '../../../../core/constants/colors.dart';
import '../widgets/registration_wrapper.dart';
import '../widgets/registration_card.dart';
import '../widgets/form_components.dart';
import '../widgets/document_thumbnail.dart';
import '../widgets/image_picker_utils.dart';
import '../registration_data_manager.dart';

import '../../../../core/utils/validators.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _data = RegistrationDataManager();

  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _aadharController;

  final FocusNode _aadharFocusNode = FocusNode();
  final FocusNode _dummyFocusNode = FocusNode();

  bool _isSaving = false;

  // ✅ ADDED: State variables for quiet inline errors (Replaces Snackbars)
  bool _showPhotoError = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _data.name);
    _dobController = TextEditingController(text: _data.dob);
    _aadharController = TextEditingController(text: _data.aadharNumber);

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
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    // ✅ Reset inline errors on new attempt
    setState(() {
      _showPhotoError = false;
      _submitError = null;
    });

    // Triggers inline red text in text fields silently
    bool isFormValid = _formKey.currentState!.validate();

    bool hasFront = _data.aadharFront != null || _data.aadharFrontUrl != null;
    bool hasBack = _data.aadharBack != null || _data.aadharBackUrl != null;

    if (!hasFront || !hasBack) {
      setState(() => _showPhotoError = true); // ✅ Quiet inline error for photos
      isFormValid = false;
    }

    // Stop silently if anything is invalid
    if (!isFormValid) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final repo = context.read<MemberRepository>();

      _data.name = _nameController.text.trim();
      _data.dob = _dobController.text.trim();
      _data.aadharNumber = _aadharController.text.trim();

      List<Future<void>> uploadTasks = [];

      if (_data.aadharFront != null) {
        uploadTasks.add(
          repo.uploadImage(uid, _data.aadharFront!, 'aadhar_front').then((url) {
            _data.aadharFrontUrl = url;
          }),
        );
      }

      if (_data.aadharBack != null) {
        uploadTasks.add(
          repo.uploadImage(uid, _data.aadharBack!, 'aadhar_back').then((url) {
            _data.aadharBackUrl = url;
          }),
        );
      }

      if (uploadTasks.isNotEmpty) {
        await Future.wait(uploadTasks);
      }

      final draftData = {
        'current_step': 2,
        'personal_details': {
          'name': _data.name,
          'dob': _data.dob,
          'gender': _data.gender,
          'aadhaar_no': _data.aadharNumber,
          'aadhaar_front_url': _data.aadharFrontUrl,
          'aadhaar_back_url': _data.aadharBackUrl,
        },
      };

      await repo.saveMemberDraft(uid: uid, data: draftData);

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pushNamed(context, AppRoutes.registrationStep2);
      }
    } catch (e, stacktrace) {
      // ✅ 1. Print the REAL error to your terminal so you can actually see it!
      debugPrint("🚨 FIREBASE SAVE ERROR: $e");
      debugPrint("🚨 STACKTRACE: $stacktrace");

      if (mounted) {
        setState(() {
          _isSaving = false;

          // ✅ 2. Show a slightly smarter UI error
          if (e.toString().contains('permission-denied')) {
            _submitError = "Permission denied. Check database rules.";
          } else if (e.toString().contains('network')) {
            _submitError = "Network error. Please check your internet.";
          } else {
            _submitError = "Something went wrong. Please try again.";
          }
        });
      }
    }
  }

  Future<void> _handleExit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

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
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

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

    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd-MM-yyyy').format(picked);
        _data.dob = _dobController.text;
      });
    }
  }

  void _pickImage(bool isFront) {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    ImagePickerUtils.showSourceSelection(
      context,
      onImagePicked: (File file) {
        setState(() {
          if (isFront) {
            _data.aadharFront = file;
          } else {
            _data.aadharBack = file;
          }
          _showPhotoError = false; // Hide error once they pick a photo
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double bottomPadding = keyboardHeight > 70
        ? keyboardHeight - 70
        : 20.0;

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
                    // ✅ Forces real-time inline validation as they type
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const RegistrationLabel("Name"),
                        RegistrationTextField(
                          controller: _nameController,
                          hint: "Full Name",
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]'),
                            ),
                          ],
                          validator: (value) =>
                              Validators.validateRequired(value, "Full Name"),
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
                              validator: (value) => Validators.validateRequired(
                                value,
                                "Date of Birth",
                              ),
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
                          maxLength: 12,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          suffixIcon: isAadharComplete
                              ? Icons.check_circle
                              : Icons.camera_alt_outlined,
                          isSuffixSuccess: isAadharComplete,
                          onSuffixTap: () {
                            if (!isAadharFrontDone) {
                              _pickImage(true);
                            } else if (!isAadharBackDone) {
                              _pickImage(false);
                            }
                          },
                          validator: Validators.validateAadhaar,
                        ),

                        if (isAadharFrontDone || isAadharBackDone)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DocumentThumbnail(
                                    title: "Front Side",
                                    file: _data.aadharFront,
                                    url: _data.aadharFrontUrl,
                                    onDelete: () => setState(() {
                                      _data.aadharFront = null;
                                      _data.aadharFrontUrl = null;
                                    }),
                                    onTap: () => _pickImage(true),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DocumentThumbnail(
                                    title: "Back Side",
                                    file: _data.aadharBack,
                                    url: _data.aadharBackUrl,
                                    onDelete: () => setState(() {
                                      _data.aadharBack = null;
                                      _data.aadharBackUrl = null;
                                    }),
                                    onTap: () => _pickImage(false),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // ✅ Quiet Inline Error for Photos
                        if (_showPhotoError)
                          Padding(
                            padding: const EdgeInsets.only(top: 12, left: 4),
                            child: Text(
                              "Both Front and Back photos are required",
                              style: GoogleFonts.roboto(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        const SizedBox(height: 30),

                        // ✅ Quiet Inline Error for Form Submission failures
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

                        // NEXT BUTTON
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
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        setState(() => _data.gender = value);
      },
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
