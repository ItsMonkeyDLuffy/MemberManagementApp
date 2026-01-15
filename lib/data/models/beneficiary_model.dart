class BeneficiaryModel {
  final String? id; // Firestore Document ID
  final String userId; // Links to the Parent Member (Foreign Key)
  final String name;
  final String relation; // e.g., "Wife", "Son"
  final String aadhaarNo; // Mandatory [cite: 146]
  final String? mobileNo; // Mandatory [cite: 143]
  final String? dob;

  BeneficiaryModel({
    this.id,
    required this.userId,
    required this.name,
    required this.relation,
    required this.aadhaarNo,
    this.mobileNo,
    this.dob,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'relation': relation,
      'aadhaar_no': aadhaarNo,
      'mobile_no': mobileNo,
      'dob': dob,
    };
  }

  factory BeneficiaryModel.fromMap(Map<String, dynamic> map, String docId) {
    return BeneficiaryModel(
      id: docId,
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      relation: map['relation'] ?? '',
      aadhaarNo: map['aadhaar_no'] ?? '',
      mobileNo: map['mobile_no'],
      dob: map['dob'],
    );
  }
}
