import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tail/screens/auth/manage_family_screen.dart'; 

class CreateParentalPin extends StatelessWidget {
  const CreateParentalPin({super.key}); 

  // --- Color Palette for HabitTail ---
  static const Color softIris = Color(0xFFD0BFFF);      // Primary Background
  static const Color electricSky = Color(0xFF98E4FF);   // Button Background
  static const Color midnightPlum = Color(0xFF3F2E5A);  // Text Color 

  // Add your family code/pin here
  static const String familyCode = "1234"; // Replace with actual generated PIN

  @override
  Widget build(BuildContext context) {  // Added missing opening brace
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
                
                // Instructions Text
                Text(
                  'Create your parental pin! Make sure to save and share with your partner! This pin enables secure account management',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: midnightPlum,
                  ),
                ),
                
                const SizedBox(height: 24),

                // --- VISUAL PIN DISPLAY BOX ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: midnightPlum.withAlpha(26), // Fixed: 0.1 * 255 ≈ 26
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    familyCode,
                    style: GoogleFonts.quicksand(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: midnightPlum,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // --- LOGO ---
                Image.asset(
                  'assets/images/icons/hbtletters.png', 
                  width: 250,                          
                  fit: BoxFit.contain,                  
                ),                                      

                const Spacer(flex: 3), 

                // --- CREATE PIN BUTTON ---
                _buildButton(
                  context: context,
                  label: "Create Pin",
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: familyCode)).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Family code copied to clipboard!"),
                          backgroundColor: midnightPlum,
                        ),
                      );
                    });
                  },
                ), 

                const SizedBox(height: 16), 

                // --- MANAGE FAMILY BUTTON ---
                _buildButton(
                  context: context,
                  label: "Create Family Members",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManageFamilyScreen()),
                    );
                  },
                ), 

                const SizedBox(height: 40), 
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