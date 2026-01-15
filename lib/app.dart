import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Member Mgmt',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      // routes: ... (Define routes in app_routes.dart later)
    );
  }
}
