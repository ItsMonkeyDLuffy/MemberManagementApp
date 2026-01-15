import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../interfaces/auth_repository.dart';

class AuthRepositoryFirebase implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<void> sendOtp({
    required String mobileNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: mobileNumber,
      verificationCompleted: (_) {},
      verificationFailed: (e) => onError(e.message ?? 'Verification Failed'),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Future<UserModel?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      // FIX: Matches the new UserModel definition from Phase 2
      return UserModel(
        uid: user.uid, // Changed from firebaseUid to uid
        mobileNo: user.phoneNumber ?? '',
        createdAt: DateTime.now(), // Required field added
        status: 'PENDING', // Default status
        role: 'member', // Default role
      );
    }
    return null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return UserModel(
        uid: user.uid,
        mobileNo: user.phoneNumber ?? '',
        createdAt: DateTime.now(), // Placeholder, normally fetched from DB
        status: 'PENDING',
      );
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
