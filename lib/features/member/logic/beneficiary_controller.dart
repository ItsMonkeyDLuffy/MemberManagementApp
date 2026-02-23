import 'package:flutter/material.dart';

// ✅ 1. Pointing to your standardized Database Model
import '../../../../data/models/user_model.dart' as db;
import '../new_member_registration/model/beneficiary_input.dart' as ui;

// ✅ 2. Use MemberRepository instead of the deleted BeneficiaryRepository
import '../../../../data/repositories/interfaces/member_repository.dart';
import '../../../../data/repositories/interfaces/auth_repository.dart';

class BeneficiaryController extends ChangeNotifier {
  final MemberRepository _memberRepo; // ✅ Updated
  final AuthRepository _authRepo;

  BeneficiaryController({
    required MemberRepository memberRepo, // ✅ Updated
    required AuthRepository authRepo,
  }) : _memberRepo = memberRepo,
       _authRepo = authRepo;

  List<db.BeneficiaryDetails> _beneficiaries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<db.BeneficiaryDetails> get beneficiaries => _beneficiaries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- LOAD LIST ---
  Future<void> loadBeneficiaries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUser = await _authRepo.getCurrentUser();
      if (currentUser?.uid != null) {
        // ✅ 3. Pull details from the main User document
        final user = await _memberRepo.getUserDetails(currentUser!.uid);
        _beneficiaries = user?.beneficiaries ?? [];
      }
    } catch (e) {
      _errorMessage = "Failed to load family: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ADD MEMBER ---
  Future<void> addFamilyMember(ui.BeneficiaryInput input) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUser = await _authRepo.getCurrentUser();
      final uid = currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      // 1. Create the new member object
      final newBeneficiary = db.BeneficiaryDetails(
        id: input.id,
        name: input.name,
        relation: input.relation,
        dob: input.dob,
        aadhaar: input.aadhar,
        gender: input.gender,
        frontUrl: input.frontUrl,
        backUrl: input.backUrl,
      );

      // 2. Add to existing list and save via MemberRepository
      final updatedList = List<db.BeneficiaryDetails>.from(_beneficiaries)
        ..add(newBeneficiary);

      await _memberRepo.saveMemberDraft(
        uid: uid,
        data: {'beneficiaries': updatedList.map((e) => e.toMap()).toList()},
      );

      // 3. Update local state
      _beneficiaries = updatedList;
    } catch (e) {
      _errorMessage = "Failed to add member: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- DELETE MEMBER ---
  Future<void> deleteMember(String id) async {
    final uid = (await _authRepo.getCurrentUser())?.uid;
    if (uid == null) return;

    final originalList = List<db.BeneficiaryDetails>.from(_beneficiaries);
    _beneficiaries.removeWhere((m) => m.id == id);
    notifyListeners();

    try {
      // ✅ 4. Save the shortened list back to the User document
      await _memberRepo.saveMemberDraft(
        uid: uid,
        data: {'beneficiaries': _beneficiaries.map((e) => e.toMap()).toList()},
      );
    } catch (e) {
      _beneficiaries = originalList;
      _errorMessage = "Failed to delete: $e";
      notifyListeners();
    }
  }
}
