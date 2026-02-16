import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/member_repository.dart';
import '../../models/user_model.dart';

class MemberRepositoryFirestore implements MemberRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  @override
  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ✅ MATCHES INTERFACE: Takes UserModel
  @override
  Future<void> createInitialUser(UserModel user) async {
    await _firestore.collection(_collection).doc(user.uid).set(user.toMap());
  }

  // ✅ MATCHES INTERFACE: Takes uid and data
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

  // ✅ MATCHES INTERFACE
  @override
  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    // Re-use saveMemberDraft logic since it does the same thing
    await saveMemberDraft(uid: uid, data: data);
  }

  // ✅ MATCHES INTERFACE
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
