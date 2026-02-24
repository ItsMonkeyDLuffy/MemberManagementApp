import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/colors.dart';
import '../screens/member_login_screen.dart';

// ✅ Import your separated screens here (Update paths as needed)
import 'active_dashboard_screen.dart';
import 'pending_approval_screen.dart';
import 'rejected_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 🚪 LOGOUT LOGIC
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MemberLoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    // ✅ STREAM BUILDER: Listens to Database Changes in Real-Time
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("User data not found."),
                  TextButton(onPressed: _logout, child: const Text("Logout")),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'INCOMPLETE';

        // 🔀 STATUS ROUTER (Now using the separated files)
        if (status == 'ACTIVE') {
          return ActiveDashboardScreen(userData: data, onLogout: _logout);
        } else if (status == 'REJECTED') {
          return RejectedScreen(userData: data, onLogout: _logout);
        } else {
          // Default for PENDING_APPROVAL or INCOMPLETE
          return PendingApprovalScreen(userData: data, onLogout: _logout);
        }
      },
    );
  }
}
