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
  // ✅ ADDED: State for URLs to load images from Firestore
  String? _currentFrontUrl;
  String? _currentBackUrl;

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

  // ✅ FIXED: Updated to use 'beneficiaries' instead of 'nominees'
  Future<void> _fetchExistingData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isInitializing = false);
      return;
    }

    try {
      final user = await context.read<MemberRepository>().getUserDetails(uid);

      if (user != null && mounted) {
        // ✅ Standardized: Read from beneficiaries (the name we set in UserModel)
        final savedList = user.beneficiaries;

        if (savedList != null && savedList.isNotEmpty) {
          setState(() {
            _data.beneficiaries = savedList.map<BeneficiaryInput>((n) {
              // ✅ Access properties directly from the BeneficiaryDetails object
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
      _currentFrontUrl = null; // ✅ Reset URL
      _currentBackUrl = null; // ✅ Reset URL
      _isAddingNew = false;
      _editingIndex = null;
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
      _currentFrontUrl = person.frontUrl; // ✅ Load URL into state
      _currentBackUrl = person.backUrl; // ✅ Load URL into state

      _editingIndex = index;
      _isAddingNew = true;
    });
  }

  void _saveBeneficiaryToList() {
    // <-- ADDED: Strongest way to kill keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      if (_selectedRelation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a relationship")),
        );
        return;
      }

      // ✅ Validation for photos (Checks File OR URL)
      bool hasFront = _currentFrontPhoto != null || _currentFrontUrl != null;
      bool hasBack = _currentBackPhoto != null || _currentBackUrl != null;

      if (_aadharController.text.isNotEmpty && (!hasFront || !hasBack)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please upload BOTH Aadhar photos"),
            backgroundColor: Colors.red,
          ),
        );
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
        frontUrl: _currentFrontUrl, // ✅ Pass URL to model
        backUrl: _currentBackUrl, // ✅ Pass URL to model
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
    // <-- ADDED: Strongest way to kill keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    setState(() => _isSaving = true);

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
          'id': person.id, // Ensure ID goes into DB
          'name': person.name,
          'relation': person.relation,
          'dob': person.dob,
          'aadhaar': person.aadhar,
          'gender': person.gender,
          'front_url': person.frontUrl, // ✅ Retain existing URL if present
          'back_url': person.backUrl, // ✅ Retain existing URL if present
          '_frontTask': frontUpload,
          '_backTask': backUpload,
        });

        if (frontUpload != null) uploadTasks.add(frontUpload);
        if (backUpload != null) uploadTasks.add(backUpload);
      }

      // Execute all image uploads concurrently
      if (uploadTasks.isNotEmpty) {
        await Future.wait(uploadTasks);
      }

      // Map the completed URLs back to the payload
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
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving beneficiaries: $e")),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // <-- ADDED: Prevent keyboard pop up on opening picker
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

    // <-- ADDED: Ensure keyboard stays closed when picker returns
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
    // ✅ MOVED: We no longer return a full Scaffold loader here.
    // This allows the Wrapper and Card to build immediately.

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double bottomPadding = keyboardHeight > 70
        ? keyboardHeight - 70
        : 10.0;

    return WillPopScope(
      onWillPop: () async {
        // <-- ADDED: Kill keyboard before going back via hardware button
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');

        Navigator.pop(context);
        return false;
      },
      child: RegistrationWrapper(
        onBack: () {
          // <-- ADDED: Kill keyboard before going back via UI arrow
          FocusManager.instance.primaryFocus?.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');

          Navigator.pop(context);
        },
        child: RegistrationCard(
          // ✅ FIX: Show loader INSIDE the card if initializing
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
                          mainAxisAlignment: MainAxisAlignment
                              .start, // ✅ Added start alignment
                          children: [
                            if (!_isAddingNew && _data.beneficiaries.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets
                                    .zero, // ✅ Removes hidden Flutter ListView padding
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
                        child: SizedBox(
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
    // ✅ Include URLs in check
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
              suffixIcon: isPhotosComplete
                  ? Icons.check_circle
                  : Icons.camera_alt_outlined,
              isSuffixSuccess: isPhotosComplete,
              onSuffixTap: () {
                // <-- ADDED: Kill keyboard before ImagePicker
                FocusManager.instance.primaryFocus?.unfocus();
                SystemChannels.textInput.invokeMethod('TextInput.hide');

                if (_currentFrontPhoto == null && _currentFrontUrl == null) {
                  ImagePickerUtils.showSourceSelection(
                    context,
                    onImagePicked: (f) =>
                        setState(() => _currentFrontPhoto = f),
                  );
                } else {
                  ImagePickerUtils.showSourceSelection(
                    context,
                    onImagePicked: (f) => setState(() => _currentBackPhoto = f),
                  );
                }
              },
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
                        url: _currentFrontUrl, // ✅ Pass URL
                        onDelete: () => setState(() {
                          _currentFrontPhoto = null;
                          _currentFrontUrl = null;
                        }),
                        onTap: () {
                          // <-- ADDED: Kill keyboard before ImagePicker
                          FocusManager.instance.primaryFocus?.unfocus();
                          SystemChannels.textInput.invokeMethod(
                            'TextInput.hide',
                          );

                          ImagePickerUtils.showSourceSelection(
                            context,
                            onImagePicked: (f) =>
                                setState(() => _currentFrontPhoto = f),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DocumentThumbnail(
                        title: "Back",
                        file: _currentBackPhoto,
                        url: _currentBackUrl, // ✅ Pass URL
                        onDelete: () => setState(() {
                          _currentBackPhoto = null;
                          _currentBackUrl = null;
                        }),
                        onTap: () {
                          // <-- ADDED: Kill keyboard before ImagePicker
                          FocusManager.instance.primaryFocus?.unfocus();
                          SystemChannels.textInput.invokeMethod(
                            'TextInput.hide',
                          );

                          ImagePickerUtils.showSourceSelection(
                            context,
                            onImagePicked: (f) =>
                                setState(() => _currentBackPhoto = f),
                          );
                        },
                      ),
                    ),
                  ],
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
        // <-- ADDED: Kill keyboard
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
          // <-- ADDED: Kill keyboard
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
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
          onChanged: (val) => setState(() => _selectedRelation = val),
        ),
      ),
    );
  }

  Widget _buildGenderSelector(String val) {
    bool isSelected = _selectedGender == val;
    return GestureDetector(
      onTap: () {
        // <-- ADDED: Kill keyboard
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
