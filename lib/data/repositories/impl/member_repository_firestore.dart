import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/member_repository.dart';
import '../../models/user_model.dart';

class MemberRepositoryFirestore implements MemberRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> checkUserExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  @override
  Future<void> createInitialUser({
    required String uid,
    required String mobileNo,
  }) async {
    // We create the doc with the UID from Authentication
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'mobile_no': mobileNo,
      'role': 'member',
      'status': 'PENDING',
      'created_at': FieldValue.serverTimestamp(),
      // 'member_id' is NOT generated here.
      // It is generated only after Admin Approval (Step 7 in PDF).
    });
  }

  @override
  Future<UserModel?> getUserDetails(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('users').doc(uid).update(data);
  }
}
