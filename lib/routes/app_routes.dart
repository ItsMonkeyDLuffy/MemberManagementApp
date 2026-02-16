import 'package:flutter/material.dart';

// Import all your screens
import '../features/shared/screens/splash_screen.dart';
import '../features/shared/screens/public_home_page.dart';
import '../features/member/screens/member_login_screen.dart';

// Registration Screens
import '../features/member/new_member_registration/screens/personal_info_screen.dart';
import '../features/member/new_member_registration/screens/bank_details_screen.dart';
import '../features/member/new_member_registration/screens/benificiary_screen.dart';
import '../features/member/new_member_registration/screens/payment_screen.dart';
import 'package:member_management_app/features/member/screens/member_home_screen.dart';

// ✅ Dashboard / Home Screen (Create this file if missing)

class AppRoutes {
  // Route Name Constants
  static const String splash = '/';
  static const String publicHome = '/public-home';
  static const String login = '/login';
  static const String otp = '/otp';

  // Registration Flow
  static const String registrationStep1 = '/registration-step1';
  static const String registrationStep2 = '/registration-step2';
  static const String registrationStep3 = '/registration-step3';
  static const String registrationStep4 = '/registration-step4';

  // ✅ ADDED THIS (Fixes PaymentScreen Error)
  static const String memberHome = '/member-home';

  // The Map that Material App looks for
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    publicHome: (context) => const PublicHomePage(),
    login: (context) => const MemberLoginScreen(),

    // Registration Flow
    registrationStep1: (context) => const PersonalInfoScreen(),
    registrationStep2: (context) => const BankDetailsScreen(),
    registrationStep3: (context) => const BeneficiaryScreen(),
    registrationStep4: (context) => const PaymentScreen(),

    // ✅ ADDED THIS
    memberHome: (context) => const MemberHomeScreen(),
  };
}
