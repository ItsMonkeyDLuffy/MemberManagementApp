import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/dharma_app_bar.dart';
import '../../../../core/enums/app_bar_type.dart';
import '../../../../core/widgets/gradient_background.dart';

import 'bank_details_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();

  // Focus Nodes
  final FocusNode _aadharFocusNode = FocusNode();
  final FocusNode _dummyFocusNode = FocusNode();

  String _selectedGender = 'Male';
  final ImagePicker _picker = ImagePicker();

  File? _aadharFront;
  File? _aadharBack;

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
  // 📸 SMART UPLOAD LOGIC
  // ==========================================

  void _handleAadharUpload() async {
    FocusScope.of(context).requestFocus(_dummyFocusNode);
    await Future.delayed(const Duration(milliseconds: 150));

    if (_aadharFront == null && _aadharBack == null) {
      _showSideSelectionSheet();
    } else if (_aadharFront != null && _aadharBack == null) {
      _showSourceSelectionSheet(isFront: false);
    } else if (_aadharFront == null && _aadharBack != null) {
      _showSourceSelectionSheet(isFront: true);
    } else {
      _showSideSelectionSheet(isEditMode: true);
    }
  }

  void _showSideSelectionSheet({bool isEditMode = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  isEditMode ? "Edit Aadhar Photo" : "Select Side to Upload",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.badge_outlined,
                  color: AppColors.primary,
                ),
                title: const Text("Aadhar Front Side"),
                trailing: _aadharFront != null
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  FocusScope.of(context).requestFocus(_dummyFocusNode);
                  Navigator.pop(ctx);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    _showSourceSelectionSheet(isFront: true);
                  });
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.flip_to_back_outlined,
                  color: AppColors.primary,
                ),
                title: const Text("Aadhar Back Side"),
                trailing: _aadharBack != null
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  FocusScope.of(context).requestFocus(_dummyFocusNode);
                  Navigator.pop(ctx);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    _showSourceSelectionSheet(isFront: false);
                  });
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showSourceSelectionSheet({required bool isFront}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  isFront ? "Upload Front Side" : "Upload Back Side",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text("Take Photo"),
                onTap: () async {
                  FocusScope.of(context).requestFocus(_dummyFocusNode);
                  Navigator.pop(ctx);
                  await Future.delayed(const Duration(milliseconds: 300));
                  _checkPermissionAndPick(ImageSource.camera, isFront);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  FocusScope.of(context).requestFocus(_dummyFocusNode);
                  Navigator.pop(ctx);
                  await Future.delayed(const Duration(milliseconds: 300));
                  _checkPermissionAndPick(ImageSource.gallery, isFront);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkPermissionAndPick(ImageSource source, bool isFront) async {
    FocusScope.of(context).requestFocus(_dummyFocusNode);

    PermissionStatus status;

    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      if (Platform.isAndroid) {
        status = await Permission.photos.request();
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.photos.request();
      }
    }

    if (status.isGranted) {
      try {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 70,
        );

        if (image != null) {
          if (isFront && _aadharFront != null) {
            await FileImage(_aadharFront!).evict();
          } else if (!isFront && _aadharBack != null) {
            await FileImage(_aadharBack!).evict();
          }

          setState(() {
            if (isFront) {
              _aadharFront = File(image.path);
            } else {
              _aadharBack = File(image.path);
            }
          });
        }
      } catch (e) {
        debugPrint("Error picking image: $e");
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Permission disabled. Open Settings?"),
            action: SnackBarAction(
              label: "Settings",
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Permission required to upload photos"),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    FocusScope.of(context).requestFocus(_dummyFocusNode);

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
    final screenWidth = MediaQuery.of(context).size.width;
    final double topBarrierHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    bool isComplete = _aadharFront != null && _aadharBack != null;

    // 🔥 MATH LOGIC: Card is 70px from bottom. We subtract that so scroll ends EXACTLY at keyboard.
    // If keyboard is closed (0), we use 20px padding.
    final double bottomPadding = keyboardHeight > 70
        ? keyboardHeight - 70
        : 20.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_dummyFocusNode),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,

        appBar: DharmaAppBar(
          type: DharmaAppBarType.custom,
          onPrimaryAction: () => Navigator.pop(context),
        ),

        body: Stack(
          children: [
            // BACKGROUND
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
                  ],
                ),
              ),
            ),

            // CARD
            Positioned(
              top: topBarrierHeight + 50,
              left: 24,
              right: 24,
              bottom: 70, // 👈 This 70px gap caused the issue
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // HEADER
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
                          Row(
                            children: [
                              _buildProgressPill(isActive: true),
                              const SizedBox(width: 8),
                              _buildProgressPill(isActive: false),
                              const SizedBox(width: 8),
                              _buildProgressPill(isActive: false),
                              const SizedBox(width: 8),
                              _buildProgressPill(isActive: false),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // SCROLLABLE AREA
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        // ✅ FIX: Using calculated padding
                        padding: EdgeInsets.fromLTRB(
                          20,
                          10,
                          20,
                          bottomPadding + 10,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Name"),
                              _buildTextField(
                                controller: _nameController,
                                hint: "Name",
                              ),
                              const SizedBox(height: 16),

                              _buildLabel("Date of Birth"),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: AbsorbPointer(
                                  child: _buildTextField(
                                    controller: _dobController,
                                    hint: "Date of Birth",
                                    readOnly: true,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

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

                              _buildLabel("Aadhar Number"),
                              _buildTextField(
                                controller: _aadharController,
                                hint: "Aadhar Number",
                                keyboardType: TextInputType.number,
                                focusNode: _aadharFocusNode,
                                suffixIcon: isComplete
                                    ? Icons.check_circle
                                    : Icons.camera_alt_outlined,
                                isSuffixSuccess: isComplete,
                                onSuffixTap: _handleAadharUpload,
                              ),

                              if (_aadharFront != null || _aadharBack != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildThumbnail(
                                          title: "Front Side",
                                          file: _aadharFront,
                                          onDelete: () => setState(
                                            () => _aadharFront = null,
                                          ),
                                          onTap: () =>
                                              _showSourceSelectionSheet(
                                                isFront: true,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildThumbnail(
                                          title: "Back Side",
                                          file: _aadharBack,
                                          onDelete: () => setState(
                                            () => _aadharBack = null,
                                          ),
                                          onTap: () =>
                                              _showSourceSelectionSheet(
                                                isFront: false,
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
                                      if (_aadharFront == null ||
                                          _aadharBack == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                                          builder: (_) =>
                                              const BankDetailsScreen(),
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

            // BOTTOM HELP
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Need Help?",
                    style: GoogleFonts.anekDevanagari(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= Helpers =================

  Widget _buildThumbnail({
    required String title,
    required File? file,
    required VoidCallback onDelete,
    required VoidCallback onTap,
  }) {
    bool hasImage = file != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: hasImage ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasImage
                ? Colors.green.withValues(alpha: 0.5)
                : Colors.grey.shade300,
            style: hasImage ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: hasImage
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      file,
                      cacheWidth: 300,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.roboto(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLabel(String text) {
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    bool isSuffixSuccess = false,
    FocusNode? focusNode,
    bool readOnly = false,
  }) {
    // ✅ HIDDEN DROPPER HANDLE
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
        style: GoogleFonts.roboto(fontSize: 15, color: AppColors.textPrimary),
        validator: (val) => val == null || val.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          hintText: hint,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.red),
          ),
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

  Widget _buildProgressPill({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
