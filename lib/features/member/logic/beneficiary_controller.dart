import 'package:flutter/material.dart';
import '../../../data/models/beneficiary_model.dart';
import '../../../data/repositories/interfaces/beneficiary_repository.dart';
import '../../../data/repositories/interfaces/auth_repository.dart';

class BeneficiaryController extends ChangeNotifier {
  final BeneficiaryRepository _repo;
  final AuthRepository _authRepo;

  BeneficiaryController({
    required BeneficiaryRepository repo,
    required AuthRepository authRepo,
  }) : _repo = repo,
       _authRepo = authRepo;

  List<BeneficiaryModel> _beneficiaries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BeneficiaryModel> get beneficiaries => _beneficiaries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load family list
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

  // Add a new member
  Future<void> addFamilyMember(
    String name,
    String relation,
    String aadhaar,
    String mobile,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = await _authRepo.getCurrentUser();
      if (currentUser?.uid == null) throw Exception("User not logged in");

      final newMember = BeneficiaryModel(
        userId: currentUser!.uid,
        name: name,
        relation: relation,
        aadhaarNo: aadhaar,
        mobileNo: mobile,
        dob: DateTime.now().toString(), // Placeholder for now
      );

      await _repo.addBeneficiary(newMember);
      await loadBeneficiaries(); // Refresh list
    } catch (e) {
      _errorMessage = "Failed to add member: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete member
  Future<void> deleteMember(String id) async {
    await _repo.deleteBeneficiary(id);
    await loadBeneficiaries();
  }
}
