import 'dart:io';

class BeneficiaryInput {
  String id;
  String name;
  String relation;
  String dob;
  String gender;
  String aadhar;
  File? frontPhoto; // Local file (New Upload)
  File? backPhoto; // Local file (New Upload)

  // ✅ NEW: Add these two fields for Database URLs
  String? frontUrl;
  String? backUrl;

  BeneficiaryInput({
    required this.id,
    required this.name,
    required this.relation,
    required this.dob,
    required this.gender,
    required this.aadhar,
    this.frontPhoto,
    this.backPhoto,
    this.frontUrl, // ✅ Add to constructor
    this.backUrl, // ✅ Add to constructor
  });
}
