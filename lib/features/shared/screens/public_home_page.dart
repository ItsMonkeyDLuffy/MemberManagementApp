import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/dharma_app_bar.dart';
import '../../../core/enums/app_bar_type.dart';
import 'package:member_management_app/routes/app_routes.dart'; // Adjust path as needed
import 'dart:math' as math;

class PublicHomePage extends StatelessWidget {
  const PublicHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: DharmaAppBar(
        type: DharmaAppBarType.publicHome,
        onPrimaryAction: () {
          Navigator.pushNamed(context, AppRoutes.login);
        },
      ),

      body: GradientBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
            // ✅ space below AppBar + 25px gap
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===============================
              // 1. MOTTO / HERO SECTION
              // ===============================
              _buildMottoSection(),
              const SizedBox(height: 10),

              // ===============================
              // 2. ABOUT OUR MISSION
              // ===============================
              _buildMissionCard(),
              const SizedBox(height: 25),

              // ===============================
              // 3. STATS (VERTICAL CARDS)
              // ===============================
              _buildStatCard(
                icon: Icons.groups,
                value: "1250+",
                label: "TOTAL MEMBERS",
              ),
              const SizedBox(height: 15),

              _buildStatCard(
                icon: Icons.favorite,
                value: "145",
                label: "HELP CASES SOLVED",
              ),
              const SizedBox(height: 15),

              _buildStatCard(
                icon: Icons.savings,
                value: "₹2,50,000+",
                label: "FUNDS DISTRIBUTED",
              ),
              const SizedBox(height: 25),

              // ===============================
              // 4. CONTACT / ASSISTANCE
              // ===============================
              _buildContactCard(),
              const SizedBox(height: 15),

              // ===============================
              // 5. FOOTER (SOCIAL PLACEHOLDER)
              // ===============================
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // MOTTO SECTION
  // ======================================================
  Widget _buildMottoSection() {
    return Column(
      children: [
        Stack(
          children: [
            Text(
              "धर्म के साथ, समाज के लिए",
              textAlign: TextAlign.center,
              style: GoogleFonts.anekDevanagari(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                // height: 1.0, // Optional: Tries to remove default padding, but Transform is safer
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1
                  ..color = const Color.fromARGB(255, 252, 125, 6),
              ),
            ),
            Text(
              "धर्म के साथ, समाज के लिए",
              textAlign: TextAlign.center,
              style: GoogleFonts.anekDevanagari(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ],
        ),
        // 1. Removed SizedBox(height: 2) entirely

        // 2. Used Transform.translate to pull this text upwards
        Transform.translate(
          offset: const Offset(
            0,
            -5,
          ), // Negative Y value moves it UP by 8 pixels
          child: Text(
            "एक ऐसा समुदाय जो संकट में साथ खड़ा होता है",
            textAlign: TextAlign.center,
            style: GoogleFonts.anekDevanagari(
              fontSize: 12,
              height:
                  1.2, // Reduced from 1.4 to tighten the text itself slightly
              color: AppColors.textPrimary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  // ======================================================
  // ABOUT MISSION CARD
  // ======================================================
  Widget _buildMissionCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About Our Mission",
            style: GoogleFonts.anekDevanagari(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            "Dharma Yodha is a revolutionary movement for the Hindu society. "
            "We are dedicated to providing support, funds, and unity to our "
            "community members in times of need.",
            style: GoogleFonts.anekDevanagari(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // STAT CARD (VERTICAL)
  // ======================================================
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 15,
      ), // Added horizontal padding
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // 1. Fixed sized spacing for the icon
          const SizedBox(width: 10),

          Icon(icon, color: Colors.white, size: 50),

          // 2. Expanded forces the Column to take all remaining space
          Expanded(
            child: Transform.translate(
              offset: const Offset(8, 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    value,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.anekDevanagari(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.0, // Optional: Reduces internal font padding
                    ),
                  ),

                  // ✅ FIX: Remove SizedBox and wrap the second text in Transform
                  Transform.translate(
                    offset: const Offset(0, -1), // Moves text UP by 5 pixels
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.anekDevanagari(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Optional: Add a dummy SizedBox here if you want to balance the icon's width
          // on the right side to make it mathematically centered, but usually
          // Expanded is enough.
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  // ======================================================
  // CONTACT / ASSISTANCE CARD
  // ======================================================
  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE3D5B0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "For further assistance please contact us -",
            style: GoogleFonts.anekDevanagari(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.call, size: 18),
              SizedBox(width: 10),
              Text("9743847498"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.email, size: 18),
              SizedBox(width: 10),
              Text("gupta.vaibhav9313@gmail.com"),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "**This app is made for the benefit of only Hindu community**",
            style: GoogleFonts.anekDevanagari(
              fontSize: 9,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // FOOTER
  // ======================================================
  // ======================================================
  // FOOTER
  // ======================================================
  Widget _buildFooter(BuildContext context) {
    // ✅ FIX 1: Pass BuildContext
    const Color iconColor = Color(0xFFFF9641);

    // ✅ FIX 2: Wrap the Row in Padding
    return Padding(
      padding: EdgeInsets.only(
        // Dynamically add the height of the phone's nav bar + a little extra space
        bottom: math.max(0.0, MediaQuery.of(context).padding.bottom - 10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // YouTube
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.youtube),
            color: iconColor, // Official YouTube Red
            iconSize: 25,
            onPressed: () {},
          ),
          const SizedBox(width: 4),

          // Facebook
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.facebook),
            color: iconColor, // Official Facebook Blue
            iconSize: 25,
            onPressed: () {},
          ),
          const SizedBox(width: 4),

          // Instagram
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.instagram),
            color: iconColor, // Official Insta Pink/Red
            iconSize: 25,
            onPressed: () {},
          ),
          const SizedBox(width: 4),

          // X (formerly Twitter)
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xTwitter),
            color: iconColor, // Official X Black
            iconSize: 25,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
