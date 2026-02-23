import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/colors.dart';
import '../screens/member_login_screen.dart';

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

        // 🔀 STATUS ROUTER
        if (status == 'ACTIVE') {
          return _buildActiveDashboardUI(data);
        } else if (status == 'REJECTED') {
          return _buildRejectedUI(data); // Updated to pass data
        } else {
          // Default for PENDING_APPROVAL or INCOMPLETE
          return _buildPendingApprovalUI(data);
        }
      },
    );
  }

  // ==========================================
  // 🕒 STATE 1: PENDING APPROVAL
  // ==========================================
  Widget _buildPendingApprovalUI(Map<String, dynamic> data) {
    final regId = data['reg_id'] ?? '...';

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
            Text(
              "Thank you for registering!\n\nYour application (ID: $regId) is being reviewed. This usually takes 24-48 hours.",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ✅ STATE 2: ACTIVE DASHBOARD (Digital ID)
  // ==========================================
  Widget _buildActiveDashboardUI(Map<String, dynamic> data) {
    final name = data['personal_details']?['name'] ?? 'Member';
    final memberId = data['member_id'] ?? 'PENDING';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Member Dashboard",
          style: GoogleFonts.anekDevanagari(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Icon(
                      Icons.verified_user,
                      size: 250,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "DIGITAL MEMBERSHIP CARD",
                              style: GoogleFonts.roboto(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.stars,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          name.toString().toUpperCase(),
                          style: GoogleFonts.oswald(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "ID: $memberId",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade400,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "ACTIVE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: QrImageView(
                                data: memberId,
                                version: QrVersions.auto,
                                size: 45.0,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Welcome to the Member Portal!"),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ❌ STATE 3: REJECTED
  // ==========================================
  Widget _buildRejectedUI(Map<String, dynamic> data) {
    final rejId = data['rejection_id'] ?? '...';
    final reason =
        data['rejection_reason'] ?? 'Please contact support for details.';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: Colors.red,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Application Rejected",
              style: GoogleFonts.anekDevanagari(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Ref ID: $rejId",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Reason: $reason",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(color: Colors.blueGrey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 40),
            TextButton(onPressed: _logout, child: const Text("Logout")),
          ],
        ),
      ),
    );
  }
}
