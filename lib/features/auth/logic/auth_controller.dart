import 'package:flutter/material.dart';
import '../../../data/repositories/interfaces/auth_repository.dart';
import '../../../data/repositories/interfaces/member_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final MemberRepository _memberRepository;

  AuthController({
    required AuthRepository authRepository,
    required MemberRepository memberRepository, // <--- Add this argument
  }) : _authRepository = authRepository,
       _memberRepository = memberRepository; // <--- Correct assignment

  bool _isLoading = false;
  String? _verificationId;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Step 1: UI calls this to send OTP
  Future<void> loginWithPhone(String phone, VoidCallback onSuccess) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.sendOtp(
        mobileNumber: phone,
        onCodeSent: (verId) {
          _verificationId = verId;
          _isLoading = false;
          notifyListeners();
          onSuccess(); // Navigate to OTP Screen
        },
        onError: (msg) {
          _errorMessage = msg;
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Step 2: UI calls this to verify
  // CHANGED: onSuccess now accepts a bool (isExistingUser)
  Future<void> verifyOtp(
    String otp,
    Function(bool isExisting) onSuccess,
  ) async {
    if (_verificationId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Verify with Firebase Auth
      final user = await _authRepository.verifyOtp(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      if (user != null) {
        // 2. Check if user exists in our Database (Firestore)
        bool exists = await _memberRepository.checkUserExists(user.uid);

        if (!exists) {
          // 3. New User? Create a profile entry
          await _memberRepository.createInitialUser(
            uid: user.uid,
            mobileNo: user.mobileNo,
          );
        }

        _isLoading = false;
        notifyListeners();

        // ✅ CALL CALLBACK WITH RESULT
        // True = Existing User -> Dashboard
        // False = New User -> Registration Step 1
        onSuccess(exists);
      } else {
        _errorMessage = "Login Failed";
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
