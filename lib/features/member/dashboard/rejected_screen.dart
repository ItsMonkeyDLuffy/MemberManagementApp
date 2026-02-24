import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RejectedScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onLogout;

  const RejectedScreen({
    super.key,
    required this.userData,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final rejId = userData['rejection_id'] ?? '...';
    final reason =
        userData['rejection_reason'] ?? 'Please contact support for details.';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: onLogout,
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
            TextButton(onPressed: onLogout, child: const Text("Logout")),
          ],
        ),
      ),
    );
  }
}
