import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // --- Color Palette for HabitTail
  static const Color softIris = Color(0xFFD0BFFF);      // Primary Background
  static const Color electricSky = Color(0xFF98E4FF);   // Button Background
  static const Color midnightPlum = Color(0xFF3F2E5A);  // Text Color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The background fills the entire screen
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Using a subtle gradient to match the bubbly look, 
          // or you can just use color: softIris
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
            // "Side Margins 20px"
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // --- LOGO ---
                // "The habit tail lettering is an image called hbtletters.png"
                Image.asset(
                  'assets/images/icons/hbtletters.png', 
                   width: 300,                          
                   fit: BoxFit.contain,                  
                ),                                      

                const Spacer(flex: 3),

                // --- LOG IN BUTTON ---
                // "Log in button will open page to Log in"
                _buildButton(
                  context: context,
                  label: "LOG IN",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPagePlaceholder()),
                    );
                  },
                ),

                const SizedBox(height: 16), // Space between buttons

                // --- CREATE ACCOUNT BUTTON ---
                // "Create Account button will open page to Sign Up page"
                _buildButton(
                  context: context,
                  label: "CREATE ACCOUNT",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPagePlaceholder()),
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

  // Helper widget to build the buttons exactly to spec
  Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity, // Full width minus padding
      height: 52, // "Button Height 52px"
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: electricSky, // "Electric Sky: Buttons"
          foregroundColor: midnightPlum, // "Midnight Plum: All readable text"
          elevation: 0, // Flat style to match design
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // "Corner Radius 12px"
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 16,       // "Size 16px"
            fontWeight: FontWeight.bold, // "Weight Bold"
            color: midnightPlum,
          ),
        ),
      ),
    );
  }
}

// --- Placeholder Pages for Navigation Testing ---

class LoginPagePlaceholder extends StatelessWidget {
  const LoginPagePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log In Form")),
      body: const Center(child: Text("This is the Log In Form Page")),
    );
  }
}

class SignUpPagePlaceholder extends StatelessWidget {
  const SignUpPagePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up Form")),
      body: const Center(child: Text("This is the Sign Up Page")),
    );
  }
}