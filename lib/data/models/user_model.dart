import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // Core Identifiers
  final String uid;
  final String mobileNo;
  final String? memberId; // Generated AFTER approval (e.g., MEM-2026-001)
  final String? regId; // Generated ON SIGNUP (e.g., REG-2026-001) ✅ ADDED

  // App Logic Fields
  final String role; // 'member', 'admin'
  final String status; // 'INCOMPLETE', 'PENDING_APPROVAL', 'ACTIVE', 'REJECTED'
  final int currentStep; // 1: Personal, 2: Bank, 3: Nominee, 4: Payment
  final DateTime createdAt;
  final DateTime updatedAt;

  // Data Sections (Nullable because they might not be filled yet)
  final PersonalDetails? personalDetails;
  final BankDetails? bankDetails;
  final List<BeneficiaryDetails>?
  beneficiaries; // ✅ Standardized to beneficiaries

  UserModel({
    required this.uid,
    required this.mobileNo,
    this.memberId,
    this.regId, // ✅ ADDED
    this.role = 'member',
    this.status = 'INCOMPLETE',
    this.currentStep = 1,
    required this.createdAt,
    required this.updatedAt,
    this.personalDetails,
    this.bankDetails,
    this.beneficiaries, // ✅ Standardized
  });

  // 1. Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'mobile_no': mobileNo,
      'member_id': memberId,
      'reg_id': regId, // ✅ SAVES TO DB
      'role': role,
      'status': status,
      'current_step': currentStep,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),

      // Only save sections if they exist
      if (personalDetails != null) 'personal_details': personalDetails!.toMap(),
      if (bankDetails != null) 'bank_details': bankDetails!.toMap(),
      if (beneficiaries != null)
        'beneficiaries': beneficiaries!
            .map((e) => e.toMap())
            .toList(), // ✅ Standardized
    };
  }

  // 2. Create Object from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      mobileNo: map['mobile_no'] ?? '',
      memberId: map['member_id'],
      regId: map['reg_id'], // ✅ LOADS FROM DB
      role: map['role'] ?? 'member',
      status: map['status'] ?? 'INCOMPLETE',
      currentStep: map['current_step'] ?? 1,

      createdAt: (map['created_at'] as Timestamp).toDate(),
      updatedAt: map['updated_at'] != null
          ? (map['updated_at'] as Timestamp).toDate()
          : DateTime.now(),

      personalDetails: map['personal_details'] != null
          ? PersonalDetails.fromMap(map['personal_details'])
          : null,

      bankDetails: map['bank_details'] != null
          ? BankDetails.fromMap(map['bank_details'])
          : null,

      // ✅ Reads 'beneficiaries', but falls back to 'nominees' so old data isn't lost
      beneficiaries: map['beneficiaries'] != null
          ? (map['beneficiaries'] as List)
                .map((e) => BeneficiaryDetails.fromMap(e))
                .toList()
          : (map['nominees'] != null
                ? (map['nominees'] as List)
                      .map((e) => BeneficiaryDetails.fromMap(e))
                      .toList()
                : []),
    );
  }

  // ✅ 3. CopyWith (Critical for updating state locally)
  UserModel copyWith({
    String? uid,
    String? mobileNo,
    String? memberId,
    String? regId,
    String? role,
    String? status,
    int? currentStep,
    DateTime? createdAt,
    DateTime? updatedAt,
    PersonalDetails? personalDetails,
    BankDetails? bankDetails,
    List<BeneficiaryDetails>? beneficiaries, // ✅ Standardized
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      mobileNo: mobileNo ?? this.mobileNo,
      memberId: memberId ?? this.memberId,
      regId: regId ?? this.regId,
      role: role ?? this.role,
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      personalDetails: personalDetails ?? this.personalDetails,
      bankDetails: bankDetails ?? this.bankDetails,
      beneficiaries: beneficiaries ?? this.beneficiaries, // ✅ Standardized
    );
  }
}

// ==========================================
// 🧩 SUB-MODELS
// ==========================================

class PersonalDetails {
  final String? name;
  final String? dob;
  final String? gender;
  final String? aadhaarNo;
  final String? panNo;
  final String? address;
  final String? aadhaarFrontUrl;
  final String? aadhaarBackUrl;

  PersonalDetails({
    this.name,
    this.dob,
    this.gender,
    this.aadhaarNo,
    this.panNo,
    this.address,
    this.aadhaarFrontUrl,
    this.aadhaarBackUrl,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'dob': dob,
    'gender': gender,
    'aadhaar_no': aadhaarNo,
    'pan_no': panNo,
    'address': address,
    'aadhaar_front_url': aadhaarFrontUrl,
    'aadhaar_back_url': aadhaarBackUrl,
  };

  factory PersonalDetails.fromMap(Map<String, dynamic> map) {
    return PersonalDetails(
      name: map['name'],
      dob: map['dob'],
      gender: map['gender'],
      aadhaarNo: map['aadhaar_no'],
      panNo: map['pan_no'],
      address: map['address'],
      aadhaarFrontUrl: map['aadhaar_front_url'],
      aadhaarBackUrl: map['aadhaar_back_url'],
    );
  }
}

class BankDetails {
  final String? accountNo;
  final String? ifsc;
  final String? bankName;
  final String? branchName;

  BankDetails({this.accountNo, this.ifsc, this.bankName, this.branchName});

  Map<String, dynamic> toMap() => {
    'account_no': accountNo,
    'ifsc': ifsc,
    'bank_name': bankName,
    'branch_name': branchName,
  };

  factory BankDetails.fromMap(Map<String, dynamic> map) {
    return BankDetails(
      accountNo: map['account_no'],
      ifsc: map['ifsc'],
      bankName: map['bank_name'],
      branchName: map['branch_name'],
    );
  }
}

// ✅ RENAMED to BeneficiaryDetails
class BeneficiaryDetails {
  final String? id; // ✅ ADDED
  final String name;
  final String relation;
  final String dob;
  final String aadhaar;
  final String gender;
  final String? frontUrl; // ✅ ADDED
  final String? backUrl; // ✅ ADDED

  BeneficiaryDetails({
    this.id, // ✅ ADDED
    required this.name,
    required this.relation,
    required this.dob,
    required this.aadhaar,
    this.gender = 'Male',
    this.frontUrl, // ✅ ADDED
    this.backUrl, // ✅ ADDED
  });

  Map<String, dynamic> toMap() => {
    'id': id, // ✅ ADDED
    'name': name,
    'relation': relation,
    'dob': dob,
    'aadhaar': aadhaar,
    'gender': gender,
    'front_url': frontUrl, // ✅ ADDED
    'back_url': backUrl, // ✅ ADDED
  };

  factory BeneficiaryDetails.fromMap(Map<String, dynamic> map) {
    return BeneficiaryDetails(
      id: map['id'], // ✅ ADDED
      name: map['name'] ?? '',
      relation: map['relation'] ?? '',
      dob: map['dob'] ?? '',
      aadhaar: map['aadhaar'] ?? '',
      gender: map['gender'] ?? 'Male',
      frontUrl: map['front_url'], // ✅ ADDED
      backUrl: map['back_url'], // ✅ ADDED
    );
  }
}
