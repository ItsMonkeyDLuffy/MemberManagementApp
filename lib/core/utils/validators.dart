class Validators {
  // Regex for Indian Mobile Number (10 digits)
  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return 'Mobile number is required';

    // Removes any white space or special chars
    String pattern = r'^[6-9]\d{9}$';
    RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  // Regex for OTP (6 digits)
  static String? validateOTP(String? value) {
    if (value == null || value.length != 6) return 'Enter 6-digit OTP';
    return null;
  }

  // Generic Required Validator (For Name, Bank Name, DOB, etc.)
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  // Aadhaar Validator (Exactly 12 digits)
  static String? validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Aadhar number is required';
    if (value.length != 12) return 'Must be exactly 12 digits';
    return null;
  }

  // Bank Account Validator (Min 9 digits)
  static String? validateAccountNo(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Account number is required';
    if (value.length < 9) return 'Account number is too short';
    return null;
  }

  // Confirm Bank Account Validator
  static String? validateConfirmAccountNo(String? value, String originalValue) {
    if (value == null || value.trim().isEmpty)
      return 'Please confirm account number';
    if (value != originalValue) return 'Account numbers do not match';
    return null;
  }

  // Strict Indian IFSC Code Validator
  static String? validateIFSC(String? value) {
    if (value == null || value.trim().isEmpty) return 'IFSC code is required';
    if (value.length != 11) return 'Must be exactly 11 characters';

    String upperVal = value.toUpperCase();

    // Check 1: First 4 must be letters
    if (!RegExp(r'^[A-Z]{4}').hasMatch(upperVal)) {
      return 'First 4 characters must be letters (e.g., SBIN)';
    }

    // Check 2: 5th character must be zero
    if (upperVal[4] != '0') {
      return "The 5th character must be a zero '0'";
    }

    // Check 3: The whole thing must be valid
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(upperVal)) {
      return 'Invalid IFSC format';
    }

    return null;
  }
}
