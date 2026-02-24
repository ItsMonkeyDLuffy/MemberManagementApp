import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart'; // ✅ Import your new routes file
import 'features/member/screens/otp_screen.dart'; // ✅ Needed for onGenerateRoute

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dharma Yodha',
      debugShowCheckedModeBanner: false,

      // ✅ APPLY THE SAFFRON THEME
      theme: AppTheme.lightTheme,

      // ✅ CHANGE 1: Use initialRoute instead of home
      // This looks up '/' in your AppRoutes.routes map
      initialRoute: AppRoutes.splash,

      // ✅ CHANGE 2: Link the routes map
      routes: AppRoutes.routes,

      // ✅ CHANGE 3: Handle the OTP Screen separately
      // Because OtpScreen requires a 'mobileNumber' parameter,
      // we handle it here to pass data during navigation.
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.otp) {
          final mobile = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => OtpScreen(mobileNumber: mobile),
          );
        }
        return null;
      },
    );
  }
}
