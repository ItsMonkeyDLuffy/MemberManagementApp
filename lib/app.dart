import 'package:flutter/material.dart';
import 'package:member_management_app/features/shared/screens/splash_screen.dart';
import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dharma Yodha',
      debugShowCheckedModeBanner: false,

      // ✅ APPLY THE SAFFRON THEME
      theme: AppTheme.lightTheme,

      // ✅ START WITH SPLASH SCREEN
      // The Splash Screen will automatically navigate to PublicHomePage after 3 seconds
      home: const SplashScreen(),
    );
  }
}
