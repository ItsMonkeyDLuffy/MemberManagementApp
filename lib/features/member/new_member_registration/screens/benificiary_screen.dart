import 'dart:io';
import 'dart:ui' as ui; // For DashedBorderPainter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
import '../widgets/document_thumbnail.dart';
import '../widgets/image_picker_utils.dart';

// ✅ Logic
import '../registration_data_manager.dart';
// ✅ Model Import
import '../model/beneficiary_input.dart';

// ✅ ADDED: Import your Validators class here
import '../../../../core/utils/validators.dart';

class BeneficiaryScreen extends StatefulWidget {
  const BeneficiaryScreen({super.key});

  @override
  State<BeneficiaryScreen> createState() => _BeneficiaryScreenState();
}

class _BeneficiaryScreenState extends State<BeneficiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _data = RegistrationDataManager(); // ✅ Singleton

  bool _isAddingNew = false;
  bool _isSaving = false;
  bool _isInitializing = true;
  int? _editingIndex;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();

  final FocusNode _aadharFocusNode = FocusNode();
  final FocusNode _dummyFocusNode = FocusNode();

  String _selectedGender = 'Male';
  String? _selectedRelation;
  File? _currentFrontPhoto;
  File? _currentBackPhoto;
  String? _currentFrontUrl;
  String? _currentBackUrl;

  // ✅ ADDED: State variables for quiet inline errors (Replaces Snackbars)
  bool _showPhotoError = false;
  bool _showRelationError = false;
  String? _submitError;

  final List<String> _relations = [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Spouse',
    'Son',
    'Daughter',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchExistingData();
  }

  Future<void> _fetchExistingData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isInitializing = false);
      return;
    }

    try {
      final user = await context.read<MemberRepository>().getUserDetails(uid);

      if (user != null && mounted) {
        final savedList = user.beneficiaries;

        if (savedList != null && savedList.isNotEmpty) {
          setState(() {
            _data.beneficiaries = savedList.map<BeneficiaryInput>((n) {
              return BeneficiaryInput(
                id: n.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: n.name,
                relation: n.relation,
                dob: n.dob,
                gender: n.gender,
                aadhar: n.aadhaar,
                frontPhoto: null,
                backPhoto: null,
                frontUrl: n.frontUrl,
                backUrl: n.backUrl,
              );
            }).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching beneficiaries: $e");
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _aadharController.dispose();
    _aadharFocusNode.dispose();
    _dummyFocusNode.dispose();
    super.dispose();
  }

  // ==========================================
  // ⚙️ LOGIC: FORM HANDLING
  // ==========================================

  void _resetForm() {
    _nameController.clear();
    _dobController.clear();
    _aadharController.clear();
    setState(() {
      _selectedGender = 'Male';
      _selectedRelation = null;
      _currentFrontPhoto = null;
      _currentBackPhoto = null;
      _currentFrontUrl = null;
      _currentBackUrl = null;
      _isAddingNew = false;
      _editingIndex = null;

      // ✅ Reset quiet errors
      _showPhotoError = false;
      _showRelationError = false;
    });
  }

  void _editBeneficiary(int index) {
    final person = _data.beneficiaries[index];
    setState(() {
      _nameController.text = person.name;
      _dobController.text = person.dob;
      _aadharController.text = person.aadhar;
      _selectedRelation = person.relation;
      _selectedGender = person.gender;
      _currentFrontPhoto = person.frontPhoto;
      _currentBackPhoto = person.backPhoto;
      _currentFrontUrl = person.frontUrl;
      _currentBackUrl = person.backUrl;

      _editingIndex = index;
      _isAddingNew = true;

      // ✅ Reset quiet errors
      _showPhotoError = false;
      _showRelationError = false;
    });
  }

  void _saveBeneficiaryToList() {
    // Kill keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusScope.of(context).unfocus();

    // ✅ Reset inline errors on new attempt
    setState(() {
      _showRelationError = false;
      _showPhotoError = false;
    });

    // Run the form validators silently
    bool isFormValid = _formKey.currentState!.validate();

    // Validate relationship quietly
    if (_selectedRelation == null) {
      setState(() => _showRelationError = true);
      isFormValid = false;
    }

    // Validate photos quietly
    bool hasFront = _currentFrontPhoto != null || _currentFrontUrl != null;
    bool hasBack = _currentBackPhoto != null || _currentBackUrl != null;

    if (_aadharController.text.isNotEmpty && (!hasFront || !hasBack)) {
      setState(() => _showPhotoError = true);
      isFormValid = false;
    }

    // If anything failed, silently stop (the red text will show on screen)
    if (!isFormValid) {
      return;
    }

    final newPerson = BeneficiaryInput(
      id: _editingIndex != null
          ? _data.beneficiaries[_editingIndex!].id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      relation: _selectedRelation!,
      dob: _dobController.text,
      gender: _selectedGender,
      aadhar: _aadharController.text,
      frontPhoto: _currentFrontPhoto,
      backPhoto: _currentBackPhoto,
      frontUrl: _currentFrontUrl,
      backUrl: _currentBackUrl,
    );

    setState(() {
      if (_editingIndex != null) {
        _data.beneficiaries[_editingIndex!] = newPerson;
      } else {
        _data.beneficiaries.add(newPerson);
      }
    });

    _resetForm();
  }

  void _deleteBeneficiary(int index) {
    setState(() {
      _data.beneficiaries.removeAt(index);
      if (_editingIndex == index) _resetForm();
    });
  }

  // ==========================================
  // 💾 LOGIC: CLOUD SAVE
  // ==========================================
  Future<void> _onNextPressed() async {
    // Kill keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    setState(() {
      _submitError = null;
      _isSaving = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final repo = context.read<MemberRepository>();

      List<Future<String>> uploadTasks = [];
      List<Map<String, dynamic>> nomineesPayload = [];

      for (var person in _data.beneficiaries) {
        Future<String>? frontUpload;
        Future<String>? backUpload;

        if (person.frontPhoto != null) {
          String fileName = 'nominee_${person.id}_front';
          frontUpload = repo.uploadImage(uid, person.frontPhoto!, fileName);
        }

        if (person.backPhoto != null) {
          String fileName = 'nominee_${person.id}_back';
          backUpload = repo.uploadImage(uid, person.backPhoto!, fileName);
        }

        nomineesPayload.add({
          'id': person.id,
          'name': person.name,
          'relation': person.relation,
          'dob': person.dob,
          'aadhaar': person.aadhar,
          'gender': person.gender,
          'front_url': person.frontUrl,
          'back_url': person.backUrl,
          '_frontTask': frontUpload,
          '_backTask': backUpload,
        });

        if (frontUpload != null) uploadTasks.add(frontUpload);
        if (backUpload != null) uploadTasks.add(backUpload);
      }

      if (uploadTasks.isNotEmpty) {
        await Future.wait(uploadTasks);
      }

      for (var payload in nomineesPayload) {
        if (payload['_frontTask'] != null) {
          payload['front_url'] = await payload['_frontTask'];
        }
        if (payload['_backTask'] != null) {
          payload['back_url'] = await payload['_backTask'];
        }
        payload.remove('_frontTask');
        payload.remove('_backTask');
      }

      final draftData = {'current_step': 4, 'nominees': nomineesPayload};

      await repo.saveMemberDraft(uid: uid, data: draftData);

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pushNamed(context, AppRoutes.registrationStep4);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _submitError =
              "Failed to save data. Please check connection."; // ✅ Quiet inline error
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    FocusScope.of(context).requestFocus(_dummyFocusNode);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
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
      });
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
        : 10.0;

    return WillPopScope(
      onWillPop: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');

        Navigator.pop(context);
        return false;
      },
      child: RegistrationWrapper(
        onBack: () {
          FocusManager.instance.primaryFocus?.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');

          Navigator.pop(context);
        },
        child: RegistrationCard(
          child: _isInitializing
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : Column(
                  children: [
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
                            "Step 3 of 4: Beneficiaries (${_data.beneficiaries.length}/5)",
                            style: GoogleFonts.anekDevanagari(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const ProgressPills(totalSteps: 4, currentStep: 3),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (!_isAddingNew && _data.beneficiaries.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _data.beneficiaries.length,
                                itemBuilder: (ctx, index) {
                                  return _buildSummaryCard(
                                    _data.beneficiaries[index],
                                    index,
                                  );
                                },
                              ),

                            if (_isAddingNew)
                              _buildInputForm()
                            else if (_data.beneficiaries.length < 5)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: _data.beneficiaries.isEmpty
                                    ? _buildBigAddButton()
                                    : _buildSmallAddButton(),
                              ),
                          ],
                        ),
                      ),
                    ),

                    if (!_isAddingNew)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          children: [
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
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _data.beneficiaries.isEmpty
                                            ? "SKIP STEP"
                                            : "NEXT: PAYMENT",
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
                  ],
                ),
        ),
      ),
    );
  }

  // ==========================================
  // 🧩 UI COMPONENTS
  // ==========================================

  Widget _buildSummaryCard(BeneficiaryInput person, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "${person.relation} • ${person.gender}",
                  style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.blueGrey,
              size: 20,
            ),
            onPressed: () => _editBeneficiary(index),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => _deleteBeneficiary(index),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    bool isPhotosComplete =
        (_currentFrontPhoto != null || _currentFrontUrl != null) &&
        (_currentBackPhoto != null || _currentBackUrl != null);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Form(
        key: _formKey,
        // ✅ Errors only show up when the user hits "Add Member", NOT while typing!
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _editingIndex != null
                      ? "Edit Beneficiary"
                      : "New Beneficiary",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _resetForm,
                ),
              ],
            ),
            const Divider(),

            const RegistrationLabel("Name"),
            RegistrationTextField(
              controller: _nameController,
              hint: "Full Name",
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              ],
              // ✅ FIXED: Using Validators
              validator: (val) => Validators.validateRequired(val, "Name"),
            ),
            const SizedBox(height: 12),

            const RegistrationLabel("Relationship"),
            _buildDropdown(),
            const SizedBox(height: 12),

            const RegistrationLabel("Date of Birth"),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: RegistrationTextField(
                  controller: _dobController,
                  hint: "Select Date",
                  readOnly: true,
                  suffixIcon: Icons.calendar_today_outlined,
                  // ✅ FIXED: Using Validators
                  validator: (val) =>
                      Validators.validateRequired(val, "Date of Birth"),
                ),
              ),
            ),
            const SizedBox(height: 12),

            const RegistrationLabel("Gender"),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildGenderSelector("Male"),
                const SizedBox(width: 15),
                _buildGenderSelector("Female"),
                const SizedBox(width: 15),
                _buildGenderSelector("Other"),
              ],
            ),
            const SizedBox(height: 12),

            const RegistrationLabel("Aadhar Number"),
            RegistrationTextField(
              controller: _aadharController,
              hint: "12 Digit Number",
              keyboardType: TextInputType.number,
              focusNode: _aadharFocusNode,
              maxLength: 12,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              suffixIcon: isPhotosComplete
                  ? Icons.check_circle
                  : Icons.camera_alt_outlined,
              isSuffixSuccess: isPhotosComplete,
              onSuffixTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                SystemChannels.textInput.invokeMethod('TextInput.hide');

                if (_currentFrontPhoto == null && _currentFrontUrl == null) {
                  ImagePickerUtils.showSourceSelection(
                    context,
                    onImagePicked: (f) {
                      setState(() {
                        _currentFrontPhoto = f;
                        _showPhotoError = false;
                      });
                    },
                  );
                } else {
                  ImagePickerUtils.showSourceSelection(
                    context,
                    onImagePicked: (f) {
                      setState(() {
                        _currentBackPhoto = f;
                        _showPhotoError = false;
                      });
                    },
                  );
                }
              },
              // ✅ FIXED: Using Validators
              validator: Validators.validateAadhaar,
            ),

            if (_currentFrontPhoto != null ||
                _currentBackPhoto != null ||
                _currentFrontUrl != null ||
                _currentBackUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: DocumentThumbnail(
                        title: "Front",
                        file: _currentFrontPhoto,
                        url: _currentFrontUrl,
                        onDelete: () => setState(() {
                          _currentFrontPhoto = null;
                          _currentFrontUrl = null;
                        }),
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          SystemChannels.textInput.invokeMethod(
                            'TextInput.hide',
                          );

                          ImagePickerUtils.showSourceSelection(
                            context,
                            onImagePicked: (f) {
                              setState(() {
                                _currentFrontPhoto = f;
                                _showPhotoError = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DocumentThumbnail(
                        title: "Back",
                        file: _currentBackPhoto,
                        url: _currentBackUrl,
                        onDelete: () => setState(() {
                          _currentBackPhoto = null;
                          _currentBackUrl = null;
                        }),
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          SystemChannels.textInput.invokeMethod(
                            'TextInput.hide',
                          );

                          ImagePickerUtils.showSourceSelection(
                            context,
                            onImagePicked: (f) {
                              setState(() {
                                _currentBackPhoto = f;
                                _showPhotoError = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // ✅ Quiet Inline Error for missing Photos
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

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _saveBeneficiaryToList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _editingIndex != null ? "UPDATE MEMBER" : "ADD MEMBER",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigAddButton() {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');

        setState(() {
          _editingIndex = null;
          _isAddingNew = true;
        });
      },
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: AppColors.primary,
          strokeWidth: 1.5,
          gap: 5.0,
          borderRadius: 16.0,
        ),
        child: Container(
          height: 150,
          width: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 35,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Add Beneficiary",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallAddButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');

          setState(() {
            _editingIndex = null;
            _isAddingNew = true;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 5),
              Text(
                "Add More",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            // ✅ Turns border red if relationship is not selected
            border: Border.all(
              color: _showRelationError ? Colors.red : Colors.grey.shade300,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRelation,
              hint: Text(
                "Select Relationship",
                style: GoogleFonts.roboto(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              isExpanded: true,
              items: _relations
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: GoogleFonts.roboto(color: AppColors.textPrimary),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedRelation = val;
                  _showRelationError =
                      false; // ✅ Clears the error when they select one
                });
              },
            ),
          ),
        ),
        // ✅ Quiet Inline Error for Dropdown
        if (_showRelationError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              "Relationship is required",
              style: GoogleFonts.roboto(color: Colors.red, fontSize: 11),
            ),
          ),
      ],
    );
  }

  Widget _buildGenderSelector(String val) {
    bool isSelected = _selectedGender == val;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');

        setState(() => _selectedGender = val);
      },
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? AppColors.primary : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 5),
          Text(
            val,
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.borderRadius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    Path dashedPath = Path();
    double dashWidth = 8.0;
    double distance = 0.0;

    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + gap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
