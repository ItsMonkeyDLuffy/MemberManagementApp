import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/dharma_app_bar.dart'; // ✅ Import New App Bar
import '/../core/enums/app_bar_type.dart';

class PublicHomePage extends StatelessWidget {
  const PublicHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 600;

    return Scaffold(
      extendBodyBehindAppBar: true, // 🔥 KEY LINE
      backgroundColor: Colors.transparent,

      // ✅ NEW: Use the Global App Bar here
      appBar: DharmaAppBar(
        type: DharmaAppBarType.publicHome,
        onPrimaryAction: () {
          Navigator.pushNamed(context, '/login');
        },
      ),

      // Body wrapped in Gradient
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,

            // 🔥 KEY FIX: push content below AppBar + status bar
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. ABOUT MISSION CARD ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "About Our Mission",
                      style: GoogleFonts.anekDevanagari(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Dharma Yodha is a revolutionary movement for the society. We are dedicated to providing support, funds, and unity to our community members in times of need.",
                      style: GoogleFonts.anekDevanagari(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- 2. STATS CARDS ---
              isDesktop
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            Icons.groups,
                            "1250+",
                            "TOTAL MEMBERS",
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildStatCard(
                            Icons.favorite,
                            "145",
                            "HELP CASES SOLVED",
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildStatCard(
                            Icons.savings,
                            "₹2,50,000+",
                            "FUNDS DISTRIBUTED",
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildStatCard(Icons.groups, "1250+", "TOTAL MEMBERS"),
                        const SizedBox(height: 15),
                        _buildStatCard(
                          Icons.favorite,
                          "145",
                          "HELP CASES SOLVED",
                        ),
                        const SizedBox(height: 15),
                        _buildStatCard(
                          Icons.savings,
                          "₹2,50,000+",
                          "FUNDS DISTRIBUTED",
                        ),
                      ],
                    ),

              const SizedBox(height: 40),

              // --- 3. FOOTER ---
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Keep your helper methods _buildStatCard and _buildFooter below)

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.anekDevanagari(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.anekDevanagari(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // ... Your Footer Content
          const Text("Footer Placeholder"),
        ],
      ),
    );
  }
}
