import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tail/screens/auth/manage_family_screen.dart';

class CreateParentalPin extends StatefulWidget {
  const CreateParentalPin({super.key});

  @override
  State<CreateParentalPin> createState() => _CreateParentalPinState();
}

class _CreateParentalPinState extends State<CreateParentalPin> {
  // --- Color Palette for HabitTail ---
  static const Color softIris = Color(0xFFD0BFFF);
  static const Color electricSky = Color(0xFF98E4FF);
  static const Color midnightPlum = Color(0xFF3F2E5A);

  String _generatedPin = '';
  bool _pinCreated = false;

  /// Generates a random 4-digit PIN
  String _generatePin() {
    final random = Random.secure();
    return List.generate(4, (_) => random.nextInt(10)).join();
  }

  /// Saves the PIN to Firestore under the current user's family
  Future<void> _createAndSavePin() async {
    final pin = _generatePin();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Store pin hash in user's document
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .update({'Parental_pin': pin});

    setState(() {
      _generatedPin = pin;
      _pinCreated = true;
    });
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
                        color: midnightPlum.withAlpha(26),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _pinCreated ? _generatedPin : '----',
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
                  label: _pinCreated ? "Copy Pin" : "Create Pin",
                  onTap: () async {
                    if (!_pinCreated) {
                      await _createAndSavePin();
                    }
                    if (_pinCreated) {
                      await Clipboard.setData(ClipboardData(text: _generatedPin));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("PIN copied to clipboard! Share with your partner."),
                            backgroundColor: midnightPlum,
                          ),
                        );
                      }
                    }
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
