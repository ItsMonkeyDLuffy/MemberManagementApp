import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // Core Identifiers
  final String uid;
  final String mobileNo;
  final String? memberId; // Generated only AFTER approval (e.g., MEM001)

  // App Logic Fields
  final String role; // 'member', 'admin'
  final String status; // 'INCOMPLETE', 'PENDING_APPROVAL', 'ACTIVE', 'REJECTED'
  final int currentStep; // 1: Personal, 2: Bank, 3: Nominee, 4: Payment
  final DateTime createdAt;
  final DateTime updatedAt;

  // Data Sections (Nullable because they might not be filled yet)
  final PersonalDetails? personalDetails;
  final BankDetails? bankDetails;
  final List<NomineeDetails>? nominees;

  UserModel({
    required this.uid,
    required this.mobileNo,
    this.memberId,
    this.role = 'member',
    this.status = 'INCOMPLETE', // Default for new users
    this.currentStep = 1, // Default start at step 1
    required this.createdAt,
    required this.updatedAt,
    this.personalDetails,
    this.bankDetails,
    this.nominees,
  });

  // 1. Convert to Map for Firestore (Handles partial data)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'mobile_no': mobileNo,
      'member_id': memberId,
      'role': role,
      'status': status,
      'current_step': currentStep,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),

      // Only save sections if they exist
      if (personalDetails != null) 'personal_details': personalDetails!.toMap(),
      if (bankDetails != null) 'bank_details': bankDetails!.toMap(),
      if (nominees != null)
        'nominees': nominees!.map((e) => e.toMap()).toList(),
    };
  }

  // 2. Create Object from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      mobileNo: map['mobile_no'] ?? '',
      memberId: map['member_id'],
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

      nominees: map['nominees'] != null
          ? (map['nominees'] as List)
                .map((e) => NomineeDetails.fromMap(e))
                .toList()
          : [],
    );
  }
}

// ==========================================
// 🧩 SUB-MODELS (Keeps Firestore Clean)
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

class NomineeDetails {
  final String name;
  final String relation;
  final String dob;
  final String aadhaar;
  final String gender; // ✅ ADDED THIS

  NomineeDetails({
    required this.name,
    required this.relation,
    required this.dob,
    required this.aadhaar,
    this.gender = 'Male', // ✅ DEFAULT VALUE FOR SAFETY
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'relation': relation,
    'dob': dob,
    'aadhaar': aadhaar,
    'gender': gender, // ✅ SAVES TO FIRESTORE
  };

  factory NomineeDetails.fromMap(Map<String, dynamic> map) {
    return NomineeDetails(
      name: map['name'] ?? '',
      relation: map['relation'] ?? '',
      dob: map['dob'] ?? '',
      aadhaar: map['aadhaar'] ?? '',
      gender: map['gender'] ?? 'Male', // ✅ LOADS FROM FIRESTORE
    );
  }
}
