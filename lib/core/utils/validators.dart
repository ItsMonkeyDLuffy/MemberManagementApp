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
}
