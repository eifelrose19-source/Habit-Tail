import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tail/screens/auth/manage_family_screen.dart';  
import 'package:habit_tail/screens/auth/join_family_screen.dart';     

class CreateOrJoinFamilyScreen extends StatelessWidget {
  const CreateOrJoinFamilyScreen({super.key});

  // --- Color Palette for HabitTail
  static const Color softIris = Color(0xFFD0BFFF);      // Primary Background
  static const Color electricSky = Color(0xFF98E4FF);   // Button Background
  static const Color midnightPlum = Color(0xFF3F2E5A);  // Text Color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Using a subtle gradient
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              softIris,
              Color(0xFFE0D4FC), // A slightly lighter shade for depth
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

                // --- LOGO --
                Image.asset(
                  'assets/images/icons/hbtletters.png', 
                  width: 300,                          
                  fit: BoxFit.contain,                  
                ),                                      

                const Spacer(flex: 3),

                // --- Create Button ---
                _buildButton(
                  context: context,
                  label: "Create Family",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageFamilyScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16), // Space between buttons

                // --- Join Family Button ---
                _buildButton(
                  context: context,
                  label: "Join Family",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JoinFamilyScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40), // Bottom spacing
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
            color: midnightPlum,
          ),
        ),
      ),
    );
  }
}