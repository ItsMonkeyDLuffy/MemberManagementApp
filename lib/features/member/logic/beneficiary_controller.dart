import 'package:flutter/material.dart';

// 1. Rename imports to avoid confusion
import '../../../../data/models/beneficiary_model.dart'
    as db; // The Database Model
import '../new_member_registration/model/beneficiary_input.dart'
    as ui; // The Form Input

import '../../../../data/repositories/interfaces/beneficiary_repository.dart';
import '../../../../data/repositories/interfaces/auth_repository.dart';

class BeneficiaryController extends ChangeNotifier {
  final BeneficiaryRepository _repo;
  final AuthRepository _authRepo;

  BeneficiaryController({
    required BeneficiaryRepository repo,
    required AuthRepository authRepo,
  }) : _repo = repo,
       _authRepo = authRepo;

  // List stores Database Models
  List<db.BeneficiaryModel> _beneficiaries = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<db.BeneficiaryModel> get beneficiaries => _beneficiaries;
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
        _beneficiaries = await _repo.getBeneficiaries(currentUser!.uid);
      }
    } catch (e) {
      _errorMessage = "Failed to load family: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ADD MEMBER ---
  // ✅ Input is 'ui.BeneficiaryInput' (from your form)
  Future<void> addFamilyMember(ui.BeneficiaryInput input) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUser = await _authRepo.getCurrentUser();
      if (currentUser?.uid == null) throw Exception("User not logged in");

      // 1. Convert UI Input -> Database Model
      final memberToSend = db.BeneficiaryModel(
        userId: currentUser!.uid,
        name: input.name,
        relation: input.relation,
        dob: input.dob,

        // ✅ Fix 1: Map 'aadhar' (UI) -> 'aadhaarNo' (DB)
        aadhaarNo: input.aadhar,

        // ❌ Removed 'gender' because your DB model doesn't have it yet.
        // If you need gender, add 'final String gender;' to BeneficiaryModel first.

        // Optional: Map mobile if your form has it, otherwise null
        mobileNo: null,
      );

      // 2. Send to Repository
      // ✅ Fix 2: Just await it. Do not try to assign it to a variable.
      await _repo.addBeneficiary(memberToSend);

      // 3. Refresh the list from server to get the new data
      await loadBeneficiaries();
    } catch (e) {
      _errorMessage = "Failed to add member: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- DELETE MEMBER ---
  Future<void> deleteMember(String id) async {
    // Optimistic update: Remove locally first for speed
    final originalList = List<db.BeneficiaryModel>.from(_beneficiaries);
    _beneficiaries.removeWhere((m) => m.id == id);
    notifyListeners();

    try {
      await _repo.deleteBeneficiary(id);
    } catch (e) {
      // If error, rollback
      _beneficiaries = originalList;
      _errorMessage = "Failed to delete: $e";
      notifyListeners();
    }
  }
}
