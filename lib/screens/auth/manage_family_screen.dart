import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tail/screens/auth/who_are_you_screen.dart';

class ManageFamilyScreen extends StatefulWidget {
  const ManageFamilyScreen({super.key});

  @override
  State<ManageFamilyScreen> createState() => _ManageFamilyScreenState();
}

class _ManageFamilyScreenState extends State<ManageFamilyScreen> {
  // Text controllers for each family member
  final TextEditingController _partnerController = TextEditingController();
  final TextEditingController _child1Controller = TextEditingController();
  final TextEditingController _child2Controller = TextEditingController();
  final TextEditingController _child3Controller = TextEditingController();

  // --- Color Palette for HabitTail ---
  static const Color softIris = Color(0xFFD0BFFF);
  static const Color electricSky = Color(0xFF98E4FF);
  static const Color midnightPlum = Color(0xFF3F2E5A);

  @override
  void dispose() {
    _partnerController.dispose();
    _child1Controller.dispose();
    _child2Controller.dispose();
    _child3Controller.dispose();
    super.dispose();
  }

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

                // Instructions Text
                Text(
                  'Create your family here. Enter your family names below:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: midnightPlum,
                  ),
                ),

                const SizedBox(height: 24),

                // Partner Name Field
                _buildTextField('Partner Name', _partnerController),
                const SizedBox(height: 16),

                // Child Fields
                _buildTextField('Child 1', _child1Controller),
                const SizedBox(height: 16),
                _buildTextField('Child 2', _child2Controller),
                const SizedBox(height: 16),
                _buildTextField('Child 3', _child3Controller),

                const SizedBox(height: 32),

                // --- LOGO ---
                Image.asset(
                  'assets/images/icons/hbtletters.png',
                  width: 250,
                  fit: BoxFit.contain,
                ),

                const Spacer(flex: 3),

                // --- Add Family BUTTON ---
                _buildButton(
                  context: context,
                  label: "Add Family",
                  onTap: () {
                    // Navigate to WhoAreYouScreen with family names
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WhoAreYouScreen(
                          partnerName: _partnerController.text.isEmpty 
                              ? 'Partner' 
                              : _partnerController.text,
                          child1Name: _child1Controller.text.isEmpty 
                              ? 'Child 1' 
                              : _child1Controller.text,
                          child2Name: _child2Controller.text.isEmpty 
                              ? 'Child 2' 
                              : _child2Controller.text,
                          child3Name: _child3Controller.text.isEmpty 
                              ? 'Child 3' 
                              : _child3Controller.text,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build text fields
  Widget _buildTextField(String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: midnightPlum.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: GoogleFonts.quicksand(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: midnightPlum,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: midnightPlum.withAlpha(128),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
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