import '../../models/user_model.dart';

abstract class MemberRepository {
  // Check if profile exists after OTP login
  Future<bool> checkUserExists(String uid);

  // Create a new empty profile immediately after first login
  Future<void> createInitialUser({
    required String uid,
    required String mobileNo,
  });

  // Update profile details (Registration Step 1)
  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  });

  // Get full user details
  Future<UserModel?> getUserDetails(String uid);
}
