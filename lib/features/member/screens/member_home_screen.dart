import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/colors.dart';
import '../../../data/repositories/interfaces/member_repository.dart';
import '../../../data/models/user_model.dart';
import 'member_login_screen.dart'; // For Logout navigation

class MemberHomeScreen extends StatefulWidget {
  const MemberHomeScreen({super.key});

  @override
  State<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  bool _isLoading = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await context.read<MemberRepository>().getUserDetails(uid);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    }
  }

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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // 1. SAFETY CHECK: If no user found
    if (_user == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    // 2. ROUTING BASED ON STATUS
    if (_user!.status == 'PENDING_APPROVAL') {
      return _buildPendingApprovalUI();
    } else if (_user!.status == 'ACTIVE') {
      return _buildActiveDashboardUI();
    } else if (_user!.status == 'REJECTED') {
      return _buildRejectedUI();
    } else {
      // Fallback (e.g., INCOMPLETE)
      return _buildPendingApprovalUI();
    }
  }

  // ==========================================
  // 🕒 STATE 1: PENDING APPROVAL
  // ==========================================
  Widget _buildPendingApprovalUI() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Application Status",
          style: GoogleFonts.anekDevanagari(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 60,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              "Application Under Review",
              textAlign: TextAlign.center,
              style: GoogleFonts.anekDevanagari(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              "Thank you for completing your registration!\n\nYour application and payment of ₹499 have been received. The admin team is currently reviewing your details.",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blueGrey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "This usually takes 24-48 hours. You will receive a notification once approved.",
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ✅ STATE 2: ACTIVE DASHBOARD (Placeholder)
  // ==========================================
  Widget _buildActiveDashboardUI() {
    return Scaffold(
      appBar: AppBar(title: const Text("Member Dashboard")),
      body: const Center(
        child: Text("🎉 WELCOME MEMBER! \n(Digital ID Card goes here)"),
      ),
    );
  }

  // ==========================================
  // ❌ STATE 3: REJECTED
  // ==========================================
  Widget _buildRejectedUI() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            Text(
              "Application Rejected",
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(onPressed: _logout, child: const Text("Logout")),
          ],
        ),
      ),
    );
  }
}
