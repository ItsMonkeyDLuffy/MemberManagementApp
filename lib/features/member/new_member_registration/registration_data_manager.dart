import 'dart:io';
import '../../../../data/models/user_model.dart'; // ✅ Import UserModel
import 'model/beneficiary_input.dart'; // ✅ Import UI Model

class RegistrationDataManager {
  // Singleton pattern
  static final RegistrationDataManager _instance =
      RegistrationDataManager._internal();
  factory RegistrationDataManager() => _instance;
  RegistrationDataManager._internal();

  // ==========================================
  // 📝 STEP 1: PERSONAL INFO
  // ==========================================
  String name = '';
  String dob = '';
  String gender = 'Male';
  String aadharNumber = '';

  // 📸 IMAGES
  File? aadharFront; // For NEW uploads
  File? aadharBack; // For NEW uploads
  String? aadharFrontUrl; // ✅ NEW: For RESUMING drafts (Cloud URL)
  String? aadharBackUrl; // ✅ NEW: For RESUMING drafts (Cloud URL)

  // ==========================================
  // 🏦 STEP 2: BANK INFO
  // ==========================================
  String accountNo = '';
  String confirmAccountNo = '';
  String ifsc = '';
  String bankName = '';

  // ==========================================
  // 👨‍👩‍👧 STEP 3: BENEFICIARIES
  // ==========================================
  List<BeneficiaryInput> beneficiaries = [];

  // ==========================================
  // 💳 STEP 4: PAYMENT & TERMS
  // ==========================================
  bool isTermsAccepted = false;

  // ==========================================
  // 📥 AUTO-FILL LOGIC (Fixed)
  // ==========================================
  void loadFromModel(UserModel user) {
    // 1. Personal Info
    if (user.personalDetails != null) {
      name = user.personalDetails!.name ?? '';
      dob = user.personalDetails!.dob ?? '';
      gender = user.personalDetails!.gender ?? 'Male';
      aadharNumber = user.personalDetails!.aadhaarNo ?? '';

      // Load URLs so UI can show "Already Uploaded" image
      aadharFrontUrl = user.personalDetails!.aadhaarFrontUrl;
      aadharBackUrl = user.personalDetails!.aadhaarBackUrl;
    }

    // 2. Bank Details
    if (user.bankDetails != null) {
      accountNo = user.bankDetails!.accountNo ?? '';
      confirmAccountNo = user.bankDetails!.accountNo ?? '';
      ifsc = user.bankDetails!.ifsc ?? '';
      bankName = user.bankDetails!.bankName ?? '';
    }

    // 3. Beneficiaries (✅ FIXED MAPPING TO BENEFICIARIES)
    if (user.beneficiaries != null) {
      beneficiaries = user.beneficiaries!.map((n) {
        return BeneficiaryInput(
          // Generate a temp ID for the UI List
          id:
              n.id ??
              (DateTime.now().millisecondsSinceEpoch.toString() + n.aadhaar),

          name: n.name,
          relation: n.relation,
          dob: n.dob,

          // ✅ FIX 1: Map 'aadhaar' from Firestore to 'aadhar' in UI
          aadhar: n.aadhaar,

          // ✅ FIX 2: Map 'gender' from Firestore
          gender: n.gender,

          // ✅ FIX 3: Load existing Cloud URLs for beneficiaries
          frontUrl: n.frontUrl,
          backUrl: n.backUrl,
        );
      }).toList();
    }
  }

  // ==========================================
  // 🗑️ CLEAR DATA
  // ==========================================
  void clearData() {
    name = '';
    dob = '';
    gender = 'Male';
    aadharNumber = '';

    // Clear both Files and URLs
    aadharFront = null;
    aadharBack = null;
    aadharFrontUrl = null;
    aadharBackUrl = null;

    accountNo = '';
    confirmAccountNo = '';
    ifsc = '';
    bankName = '';

    beneficiaries.clear();
    isTermsAccepted = false;
  }
}
