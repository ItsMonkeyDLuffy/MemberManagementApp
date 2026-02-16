import 'package:flutter/material.dart';
import '../../../data/repositories/interfaces/auth_repository.dart';
import '../../../data/repositories/interfaces/member_repository.dart';
import '../../../data/models/user_model.dart';
import '../../member/new_member_registration/registration_data_manager.dart'; // import '../../../routes/app_routes.dart'; // ✅ Added for Route Constants
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

  // ==========================================
  // 2️⃣ VERIFY OTP & ROUTE USER
  // ==========================================
  Future<void> verifyOtp(
    String otp,
    Function(String routeName) onNavigate,
  ) async {
    if (_verificationId == null) return;

    _isLoading = true;
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
              existingUser.status == 'PENDING_APPROVAL') {
            RegistrationDataManager().clearData();
            _isLoading = false;
            notifyListeners();
            // ✅ Use AppRoutes constant
            onNavigate(AppRoutes.memberHome);
          } else {
            // ⚠️ INCOMPLETE APPLICATION -> RESUME DRAFT
            RegistrationDataManager().loadFromModel(existingUser);

            _isLoading = false;
            notifyListeners();

            // ✅ Map currentStep to AppRoutes constants
            int step = existingUser.currentStep;
            if (step == 2) {
              onNavigate(AppRoutes.registrationStep2);
            } else if (step == 3) {
              onNavigate(AppRoutes.registrationStep3);
            } else if (step == 4) {
              onNavigate(AppRoutes.registrationStep4);
            } else {
              onNavigate(AppRoutes.registrationStep1);
            }
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
          // ✅ Use AppRoutes constant
          onNavigate(AppRoutes.registrationStep1);
        }
      } else {
        _errorMessage = "Verification failed. Try again.";
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Error: $e";
      notifyListeners();
    }
  }
}
