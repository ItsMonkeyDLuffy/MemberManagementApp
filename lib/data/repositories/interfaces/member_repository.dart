import '../../models/user_model.dart';

abstract class MemberRepository {
  // 1. Check if user exists
  Future<bool> checkUserExists(String uid);

  // 2. Create the initial user (Must take UserModel)
  Future<void> createInitialUser(UserModel user);

  // 3. Save Draft (The new method for auto-saving)
  Future<void> saveMemberDraft({
    required String uid,
    required Map<String, dynamic> data,
  });

  // 4. Update Profile (Legacy method, useful for specific updates)
  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  });

  // 5. Get User Details
  Future<UserModel?> getUserDetails(String uid);
}
