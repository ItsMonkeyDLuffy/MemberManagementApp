import 'dart:io';

// ⚠️ Renamed from BeneficiaryModel to BeneficiaryInput
class BeneficiaryInput {
  final String name;
  final String relation;
  final String dob;
  final String gender; // UI has gender, Data model might need it added later
  final String aadhar;
  final File? frontPhoto; // Only needed in UI for upload
  final File? backPhoto; // Only needed in UI for upload

  BeneficiaryInput({
    required this.name,
    required this.relation,
    required this.dob,
    required this.gender,
    required this.aadhar,
    this.frontPhoto,
    this.backPhoto,
  });
}
