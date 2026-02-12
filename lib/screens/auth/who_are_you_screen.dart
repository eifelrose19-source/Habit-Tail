import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WhoAreYouScreen extends StatelessWidget {
  final String partnerName;
  final String child1Name;
  final String child2Name;
  final String child3Name;

  const WhoAreYouScreen({
    super.key,
    required this.partnerName,
    required this.child1Name,
    required this.child2Name,
    required this.child3Name,
  });

  // --- Color Palette for HabitTail ---
  static const Color softIris = Color(0xFFD0BFFF);
  static const Color electricSky = Color(0xFF98E4FF);
  static const Color midnightPlum = Color(0xFF3F2E5A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              softIris,
              Color(0xFFE0D4FC),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Title Text
                Text(
                  'Who are you?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: midnightPlum,
                  ),
                ),

                const SizedBox(height: 24),

                // --- LOGO ---
                Image.asset(
                  'assets/images/icons/hbtletters.png',
                  width: 250,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 24),

                // "Who are you?" text below logo
                Text(
                  'Who are you?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: midnightPlum,
                  ),
                ),

                const SizedBox(height: 32),

                // --- SELECTION BUTTONS ---
                _buildButton(
                  context: context,
                  label: partnerName,
                  onTap: () {
                    // Navigate to parent dashboard
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => ParentDashboardScreen()));
                  },
                ),

                const SizedBox(height: 16),

                _buildButton(
                  context: context,
                  label: child1Name,
                  onTap: () {
                    // Navigate to child 1 dashboard
                  },
                ),

                const SizedBox(height: 16),

                _buildButton(
                  context: context,
                  label: child2Name,
                  onTap: () {
                    // Navigate to child 2 dashboard
                  },
                ),

                const SizedBox(height: 16),

                _buildButton(
                  context: context,
                  label: child3Name,
                  onTap: () {
                    // Navigate to child 3 dashboard
                  },
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build the buttons
  Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: electricSky,
          foregroundColor: midnightPlum,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}