import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PartnerPinScreen extends StatefulWidget {
  const PartnerPinScreen({super.key});

  @override
  State<PartnerPinScreen> createState() => _PartnerPinScreenState();
}

class _PartnerPinScreenState extends State<PartnerPinScreen> {
  // Controllers for each PIN digit
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  // Focus nodes for each PIN field
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  // --- Color Palette for HabitTail ---
  static const Color softIris = Color(0xFFD0BFFF);
  static const Color electricSky = Color(0xFF98E4FF);
  static const Color midnightPlum = Color(0xFF3F2E5A);

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyPin() {
    String enteredPin = _pinControllers.map((c) => c.text).join();
    
    // TODO: Replace with actual PIN verification logic
    const String correctPin = "1234"; // This should come from your saved PIN
    
    if (enteredPin == correctPin) {
      // Navigate to parent dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PIN verified successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      // Navigator.push(context, MaterialPageRoute(builder: (context) => ParentDashboardScreen()));
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect PIN. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
      // Clear all fields
      for (var controller in _pinControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
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

                // Title Text
                Text(
                  'Partner Pin',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: midnightPlum,
                  ),
                ),

                const SizedBox(height: 32),

                // --- LOGO ---
                Image.asset(
                  'assets/images/icons/hbtletters.png',
                  width: 250,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 32),

                // Instructions Text
                Text(
                  'Enter 4 digit Parental\nPIN to Proceed',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: midnightPlum,
                  ),
                ),

                const SizedBox(height: 24),

                // --- PIN INPUT BOXES ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildPinBox(index),
                    );
                  }),
                ),

                const Spacer(flex: 2),

                // --- VERIFY BUTTON ---
                _buildButton(
                  context: context,
                  label: "VERIFY",
                  onTap: _verifyPin,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build PIN input box
  Widget _buildPinBox(int index) {
    return Container(
      width: 60,
      height: 60,
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
        controller: _pinControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: true,
        style: GoogleFonts.quicksand(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: midnightPlum,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          if (value.length == 1 && index < 3) {
            // Move to next field
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            // Move to previous field on backspace
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  // Helper widget to build the button
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