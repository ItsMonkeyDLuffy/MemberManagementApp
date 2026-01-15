import '../../models/user_model.dart';

abstract class AuthRepository {
  // Step 1: Request OTP
  Future<void> sendOtp({
    required String mobileNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  });

  // Step 2: Verify OTP and return the User
  Future<UserModel?> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  // Check if user is already logged in
  Future<UserModel?> getCurrentUser();

  Future<void> logout();
}
