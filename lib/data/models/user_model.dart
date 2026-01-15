import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid; // Firebase Auth ID
  final String mobileNo;
  final String? memberId; // The sequential ID (e.g., MEM001)
  final String role; // 'member', 'admin', 'maker', 'checker'
  final String status; // 'PENDING', 'VERIFIED', 'REJECTED'
  final DateTime createdAt;

  // Profile Details (Grouped for cleanliness)
  final String? name;
  final String? aadhaarNo;
  final String? panNo;
  final String? address;

  UserModel({
    required this.uid,
    required this.mobileNo,
    this.memberId,
    this.role = 'member',
    this.status = 'PENDING',
    required this.createdAt,
    this.name,
    this.aadhaarNo,
    this.panNo,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'mobile_no': mobileNo,
      'member_id': memberId,
      'role': role,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'name': name,
      'aadhaar_no': aadhaarNo,
      'pan_no': panNo,
      'address': address,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      mobileNo: map['mobile_no'] ?? '',
      memberId: map['member_id'],
      role: map['role'] ?? 'member',
      status: map['status'] ?? 'PENDING',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      name: map['name'],
      aadhaarNo: map['aadhaar_no'],
      panNo: map['pan_no'],
      address: map['address'],
    );
  }
}
