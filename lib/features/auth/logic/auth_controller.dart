import 'package:flutter/material.dart';
import '../../../data/repositories/interfaces/auth_repository.dart';
import '../../../data/repositories/interfaces/member_repository.dart';
import '../../../data/models/user_model.dart';
import '../../member/new_member_registration/registration_data_manager.dart';
import 'package:member_management_app/routes/app_routes.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final MemberRepository _memberRepository;

  AuthController({
    required AuthRepository authRepository,
    required MemberRepository memberRepository,
  }) : _authRepository = authRepository,
       _memberRepository = memberRepository;

  bool _isLoading = false;
  String? _verificationId;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ✅ ADDED: This clears the error from memory when navigating back
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // ✅ ADDED: Filter to translate ugly Firebase errors into clean UI text
  String _cleanErrorMessage(dynamic e) {
    String error = e.toString();
    if (error.contains('invalid-verification-code')) {
      return "The OTP entered is incorrect. Please try again.";
    } else if (error.contains('invalid-phone-number')) {
      return "Please enter a valid mobile number.";
    } else if (error.contains('too-many-requests')) {
      return "Too many attempts. Please try again later.";
    } else if (error.contains('network-request-failed')) {
      return "No internet connection. Please check your network.";
    } else if (error.contains('session-expired')) {
      return "This OTP has expired. Please go back and request a new one.";
    }
    return "Something went wrong. Please try again.";
  }

  // ==========================================
  // 1️⃣ SEND OTP
  // ==========================================
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
          onSuccess();
        },
        onError: (msg) {
          // ✅ Clean the error before it hits the UI
          _errorMessage = _cleanErrorMessage(msg);
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      // ✅ Clean the error before it hits the UI
      _errorMessage = _cleanErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 2️⃣ VERIFY OTP & ROUTE USER
  // ==========================================
  Future<void> verifyOtp(
    String otp,
    Function(String routeName) onNavigate,
  ) async {
    if (_verificationId == null) return;

    _isLoading = true;
    _errorMessage = null; // ✅ Clear old errors on new attempt
    notifyListeners();

    try {
      final firebaseUser = await _authRepository.verifyOtp(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      if (firebaseUser != null) {
        UserModel? existingUser = await _memberRepository.getUserDetails(
          firebaseUser.uid,
        );

        if (existingUser != null) {
          // --- SCENARIO 1: EXISTING USER ---
          if (existingUser.status == 'ACTIVE' ||
              existingUser.status == 'PENDING_APPROVAL' ||
              existingUser.paymentStatus == 'COMPLETED') {
            RegistrationDataManager().clearData();
            _isLoading = false;
            notifyListeners();
            onNavigate(AppRoutes.memberHome);
          } else {
            // ⚠️ INCOMPLETE APPLICATION -> RESUME DRAFT
            RegistrationDataManager().loadFromModel(existingUser);

            _isLoading = false;
            notifyListeners();

            // ✅ BULLETPROOF FIX: Always navigate to Step 1
            onNavigate(AppRoutes.registrationStep1);
          }
        } else {
          // --- SCENARIO 2: NEW USER ---
          final newUser = UserModel(
            uid: firebaseUser.uid,
            mobileNo: firebaseUser.mobileNo,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            status: 'INCOMPLETE',
            currentStep: 1,
          );

          await _memberRepository.createInitialUser(newUser);

          RegistrationDataManager().clearData();
          _isLoading = false;
          notifyListeners();
          onNavigate(AppRoutes.registrationStep1);
        }
      } else {
        _errorMessage = "The OTP entered is incorrect. Please try again.";
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      // ✅ Clean the error before it hits the UI
      _errorMessage = _cleanErrorMessage(e);
      notifyListeners();
    }
  }
}
