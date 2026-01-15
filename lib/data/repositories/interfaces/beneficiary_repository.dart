import '../../models/beneficiary_model.dart';

abstract class BeneficiaryRepository {
  // Add a new family member
  Future<void> addBeneficiary(BeneficiaryModel beneficiary);

  // Get all family members for a specific user
  Future<List<BeneficiaryModel>> getBeneficiaries(String userId);

  // Remove a family member
  Future<void> deleteBeneficiary(String beneficiaryId);
}
