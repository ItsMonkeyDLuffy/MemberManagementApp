import 'dart:io';

class BeneficiaryInput {
  final String id; // ✅ Added ID (Needed for deleting items from list)
  final String name;
  final String relation;
  final String dob;
  final String gender;
  final String aadhar;
  final File? frontPhoto;
  final File? backPhoto;

  BeneficiaryInput({
    required this.id, // ✅ Required
    required this.name,
    required this.relation,
    required this.dob,
    required this.gender,
    required this.aadhar,
    this.frontPhoto,
    this.backPhoto,
  });
}
