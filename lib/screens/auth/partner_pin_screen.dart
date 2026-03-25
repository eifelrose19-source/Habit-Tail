import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../parent_ui/parent_dashboard_screen.dart';

class PartnerPinScreen extends StatefulWidget {
  const PartnerPinScreen({super.key});

  @override
  State<PartnerPinScreen> createState() => _PartnerPinScreenState();
}

class _PartnerPinScreenState extends State<PartnerPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  // --- HabitTail Color Palette ---
  static const Color softIris = Color(0xFFD0BFFF);
  static const Color electricSky = Color(0xFF98E4FF);
  static const Color midnightPlum = Color(0xFF3F2E5A);
  static const Color errorRed = Color(0xFFE57373);

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, Color bgColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.quicksand(fontWeight: FontWeight.w500),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _verifyPin(String enteredPin) async {
    setState(() => _isLoading = true);

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        _showSnackbar("User session not found. Please log in again.", Colors.orange);
        return;
      }

      // Fetch the document matching your Firestore screenshot
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        _showSnackbar("User profile not found in database.", errorRed);
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final String? storedPin = data['parentalPin'];

      if (storedPin == null) {
        _showSnackbar("No Parental PIN has been set yet.", Colors.orange);
      } else if (enteredPin == storedPin) {
        _showSnackbar("Access Granted", Colors.green);
        if (enteredPin == storedPin) {
          //Navigate to Parent Dashboard
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ParentDashboardScreen(),
            ),
          );
        }
      } else {
        _showSnackbar("Incorrect PIN. Please try again.", errorRed);
        _pinController.clear();
        _focusNode.requestFocus();
      }
    } catch (e) {
      _showSnackbar("Connection Error: ${e.toString()}", errorRed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pinput Theme Setup
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: GoogleFonts.quicksand(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: midnightPlum,
      ),
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
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: electricSky, width: 2),
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [softIris, Color(0xFFE0D4FC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  Text(
                    'Partner Pin',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: midnightPlum,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Image.asset(
                    'assets/images/icons/hbtletters.png',
                    width: 220,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 40),

                  Text(
                    'Enter 4 digit Parental\nPIN to Proceed',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: midnightPlum,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pinput Widget
                  Pinput(
                    length: 4,
                    controller: _pinController,
                    focusNode: _focusNode,
                    obscureText: true,
                    obscuringCharacter: '●',
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: _verifyPin,
                    cursor: Container(
                      width: 2,
                      height: 20,
                      color: electricSky,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _verifyPin(_pinController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: electricSky,
                        foregroundColor: midnightPlum,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: midnightPlum)
                          : Text(
                              'VERIFY',
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}