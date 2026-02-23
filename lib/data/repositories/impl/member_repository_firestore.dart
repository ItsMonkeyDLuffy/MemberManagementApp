import 'dart:io'; // ✅ Needed for File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ✅ Needed for Storage
import '../interfaces/member_repository.dart';
import '../../models/user_model.dart';

class MemberRepositoryFirestore implements MemberRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // ---------------------------------------------------------
  // 1️⃣ HELPER: GENERATE NEXT ID (REG-2026-001)
  // ---------------------------------------------------------
  Future<String> _generateNextId(String prefix) async {
    final currentYear = DateTime.now().year.toString();
    final counterDocRef = _firestore
        .collection('counters')
        .doc('${prefix}_$currentYear');

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterDocRef);

      int nextNumber = 1;
      if (snapshot.exists) {
        // If counter exists, increment it
        nextNumber = (snapshot.data()?['current_count'] ?? 0) + 1;
      }

      // Save the new count (e.g., 5 -> 6)
      transaction.set(counterDocRef, {
        'current_count': nextNumber,
      }, SetOptions(merge: true));

      // Return formatted ID: "REG-2026-006"
      return '$prefix-$currentYear-${nextNumber.toString().padLeft(3, '0')}';
    });
  }

  // ---------------------------------------------------------
  // 2️⃣ CREATE INITIAL USER (Now with Auto-ID!)
  // ---------------------------------------------------------
  @override
  Future<void> createInitialUser(UserModel user) async {
    try {
      // ✅ Step A: Generate the unique REG ID
      String newRegId = await _generateNextId('REG');

      // ✅ Step B: Add it to the user object
      UserModel newUser = user.copyWith(regId: newRegId);

      // ✅ Step C: Save to Firestore
      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .set(newUser.toMap());
    } catch (e) {
      throw Exception("Failed to create user: $e");
    }
  }

  // ---------------------------------------------------------
  // 3️⃣ UPLOAD IMAGE TO FIREBASE STORAGE
  // ---------------------------------------------------------
  @override
  Future<String> uploadImage(String uid, File file, String fileName) async {
    try {
      // Create a reference: member_documents/UID/filename.jpg
      final ref = FirebaseStorage.instance
          .ref()
          .child('member_documents')
          .child(uid)
          .child('$fileName.jpg');

      // Upload the file
      final uploadTask = await ref.putFile(file);

      // Get the download URL (https://...)
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }

  // ---------------------------------------------------------
  // 4️⃣ ADMIN FUNCTIONS: APPROVE & REJECT (✅ ADDED THESE)
  // ---------------------------------------------------------

  @override
  Future<void> approveMember(String uid) async {
    try {
      // Generate the Permanent Member ID (MEM-2026-XXX)
      String memberId = await _generateNextId('MEM');

      await _firestore.collection(_collection).doc(uid).update({
        'status': 'ACTIVE',
        'member_id': memberId,
        'updated_at': FieldValue.serverTimestamp(),
        'approved_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Approval failed: $e");
    }
  }

  @override
  Future<void> rejectMember(String uid, String reason) async {
    try {
      // Generate a Rejection ID (REJ-2026-XXX)
      String rejId = await _generateNextId('REJ');

      await _firestore.collection(_collection).doc(uid).update({
        'status': 'REJECTED',
        'rejection_id': rejId,
        'rejection_reason': reason,
        'updated_at': FieldValue.serverTimestamp(),
        'rejected_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Rejection failed: $e");
    }
  }

  // ---------------------------------------------------------
  // STANDARD METHODS
  // ---------------------------------------------------------

  @override
  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveMemberDraft({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(_collection).doc(uid).set({
      ...data,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await saveMemberDraft(uid: uid, data: data);
  }

  @override
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
