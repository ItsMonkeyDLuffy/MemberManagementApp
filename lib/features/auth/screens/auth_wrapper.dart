import 'package:member_management_app/features/member/screens/member_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../logic/auth_controller.dart';
import '../../member/dashboard/dashboard_screen.dart';
import '../../member/new_member_registration/screens/personal_info_screen.dart';
import 'package:member_management_app/routes/app_routes.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 1. Loading state while checking Firebase session
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. User is logged in -> Decide which screen to show
        if (authSnapshot.hasData && authSnapshot.data != null) {
          return FutureBuilder<String>(
            future: context.read<AuthController>().getInitialRoute(
              authSnapshot.data!.uid,
            ),
            builder: (context, routeSnapshot) {
              if (routeSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final targetRoute = routeSnapshot.data ?? AppRoutes.login;

              if (targetRoute == AppRoutes.memberHome) {
                return const DashboardScreen();
              } else if (targetRoute == AppRoutes.registrationStep1) {
                return const PersonalInfoScreen();
              }
              return const MemberLoginScreen();
            },
          );
        }

        // 3. User is NOT logged in
        return const MemberLoginScreen();
      },
    );
  }
}
