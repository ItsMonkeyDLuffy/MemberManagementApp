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
      // ✅ FIX: Added 'updatedAt' and correct default values
      return UserModel(
        uid: user.uid,
        mobileNo: user.phoneNumber ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(), // 🟢 Added this required field
        status: 'INCOMPLETE', // 🟢 Changed default to INCOMPLETE for new flow
        role: 'member',
        currentStep: 1, // 🟢 Default start step
      );
    }
    return null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // Note: This returns a basic object.
      // ideally, you should fetch the full profile from Firestore here.
      return UserModel(
        uid: user.uid,
        mobileNo: user.phoneNumber ?? '',
        createdAt: DateTime.now(), // Placeholder
        updatedAt: DateTime.now(), // 🟢 Added this required field
        status: 'PENDING',
        currentStep: 1,
      );
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
