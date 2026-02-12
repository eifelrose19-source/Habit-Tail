import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tail/screens/auth/manage_family_screen.dart'; 

class CreateFamilyCode extends StatelessWidget {
  const CreateFamilyCode({super.key}); 

  // --- Color Palette for HabitTail ---
  static const Color softIris = Color(0xFFD0BFFF);      // Primary Background
  static const Color electricSky = Color(0xFF98E4FF);   // Button Background
  static const Color midnightPlum = Color(0xFF3F2E5A);  // Text Color 

  @override
  Widget build(BuildContext context) {
    // This is the family code variable I will later make dynamic
    const String familyCode = "FAM-8534";

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
                  'Below is your family code! Copy and share with family to create your family account!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: midnightPlum,
                  ),
                ),
                
                const SizedBox(height: 24),

                // --- VISUAL CODE DISPLAY BOX ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: midnightPlum.withAlpha((0.1 * 255).round()),,
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

                // --- COPY CODE BUTTON ---
                _buildButton(
                  context: context,
                  label: "Copy Code",
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: familyCode)).then((_) {
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
