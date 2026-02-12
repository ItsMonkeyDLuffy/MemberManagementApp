import 'dart:io';
import 'model/beneficiary_input.dart'; // ✅ Import the UI Input Model

class RegistrationDataManager {
  // Singleton pattern
  static final RegistrationDataManager _instance =
      RegistrationDataManager._internal();
  factory RegistrationDataManager() => _instance;
  RegistrationDataManager._internal();

  // --- Step 1: Personal Info ---
  String name = '';
  String dob = '';
  String gender = 'Male';
  String aadharNumber = '';
  File? aadharFront;
  File? aadharBack;

  // --- Step 2: Bank Details ---
  String accountNo = '';
  String confirmAccountNo = '';
  String ifsc = '';
  String bankName = '';

  // --- Step 3: Beneficiaries ---
  // ✅ Updated to use the UI Input model
  List<BeneficiaryInput> beneficiaries = [];

  // --- Step 4: Payment ---
  bool isTermsAccepted = false;

  // 🗑️ Clear Data (Call this when user confirms exit)
  void clearData() {
    name = '';
    dob = '';
    gender = 'Male';
    aadharNumber = '';
    aadharFront = null;
    aadharBack = null;
    accountNo = '';
    confirmAccountNo = '';
    ifsc = '';
    bankName = '';
    beneficiaries.clear();
    isTermsAccepted = false;
  }
}
