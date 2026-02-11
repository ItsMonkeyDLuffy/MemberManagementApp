import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/dharma_app_bar.dart';
import '../../../../core/enums/app_bar_type.dart';
import '../../../../core/widgets/gradient_background.dart';

// Next: This will likely navigate to the Dashboard upon success
// import '../member_home_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  void _handlePayment() {
    // TODO: Integrate Razorpay / Stripe / UPI here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment Gateway Integration Pending..."),
        backgroundColor: Color(0xFFE89956),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double topBarrierHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: DharmaAppBar(
        title: "Registration",
        type: DharmaAppBarType.custom,
        onPrimaryAction: () => Navigator.pop(context),
      ),

      body: Stack(
        children: [
          // ============================================
          // LAYER 1: STATIC BACKGROUND
          // ============================================
          Positioned.fill(
            child: GradientBackground(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: topBarrierHeight + 15,
                    bottom: 0,
                    left: -42,
                    width: screenWidth + 60,
                    child: Opacity(
                      opacity: 0.3,
                      child: Image.asset(
                        'assets/images/saffron_flag_bg.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.topLeft,
                      ),
                    ),
                  ),

                  // FOOTER
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: _buildFooter(),
                  ),
                ],
              ),
            ),
          ),

          // ============================================
          // LAYER 2: SCROLLABLE CARD
          // ============================================
          Column(
            children: [
              SizedBox(height: topBarrierHeight),

              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // GLASS CARD
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. HEADER
                            Text(
                              "MEMBER REGISTRATION",
                              style: GoogleFonts.anekDevanagari(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE89956),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Step 4 of 4: Payment",
                              style: GoogleFonts.anekDevanagari(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 2. PROGRESS BAR (All 4 Active)
                            Row(
                              children: [
                                _buildProgressPill(isActive: true),
                                const SizedBox(width: 8),
                                _buildProgressPill(isActive: true),
                                const SizedBox(width: 8),
                                _buildProgressPill(isActive: true),
                                const SizedBox(width: 8),
                                _buildProgressPill(
                                  isActive: true,
                                ), // Final Step
                              ],
                            ),
                            const SizedBox(height: 40),

                            // 3. PAYMENT INFO TEXT
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                "To complete your registration and become a verified member of Dharma Yodha app, a non-refundable payment of ₹499 is required.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  color: const Color(0xFFE89956), // Orange Text
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // 4. PAY BUTTON
                            SizedBox(
                              width: 140, // Smaller width as per image
                              height: 45,
                              child: ElevatedButton(
                                onPressed: _handlePayment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE89956),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  "PAY",
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // 5. TERMS DISCLAIMER
                            Text(
                              "**By Paying you agree to all the TERMS & CONDITIONS**",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 10,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: keyboardHeight),
            ],
          ),
        ],
      ),
    );
  }

  // ================= Helpers =================

  Widget _buildProgressPill({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE89956) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    const Color iconColor = Color(0xFFE89956);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.youtube),
          color: iconColor,
          iconSize: 20,
          onPressed: () {},
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.facebook),
          color: iconColor,
          iconSize: 20,
          onPressed: () {},
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.xTwitter),
          color: iconColor,
          iconSize: 20,
          onPressed: () {},
        ),
      ],
    );
  }
}
