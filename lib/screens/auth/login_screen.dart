import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              Color(0xFFD0BFFF),
              Color(0xFFFFADBC),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  //Logo
                  Image.asset(
                    'assets/images/icons/hbtletters.png',
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                  
                  const SizedBox(height: 60),

                  //Email input
                  Text(
                    'Email:',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3F2E5A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _emailController,
                    hint: 'email@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 24),

                  //Password Input
                  Text(
                    'Password:',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3F2E5A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _passwordController,
                    hint: '••••••••••••',
                    isPassword: true,
                  ),
                  const SizedBox(height: 8),

                  //Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        //ToDo: Navigate to forgot password screen
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3F2E5A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  //Log In Button
                  _buildPrimaryButton(
                    label: 'Log In',
                    onTap: () {
                      //ToDo: Add authentication logic here
                      Navigator.pushNamed(context, '/create-or-join-family');
                    },
                  ),
                  const SizedBox(height: 32),

                  // --- OR DIVIDER ---
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFF3F2E5A))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Or Log in with',
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3F2E5A),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFF3F2E5A))),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- GOOGLE SIGN IN ---
                  _buildSocialButton(
                    label: 'Log in with Google',
                    icon: Icons.g_mobiledata,
                    onTap: () {
                      // TODO: Implement Google Sign In
                    },
                  ),

                  const SizedBox(height: 16),

                  // --- APPLE SIGN IN ---
                  _buildSocialButton(
                    label: 'Log in with Apple',
                    icon: Icons.apple,
                    onTap: () {
                      // TODO: Implement Apple Sign In
                    },
                  ),

                  const SizedBox(height: 32),

                  // --- SIGN UP LINK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3F2E5A),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3F2E5A),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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

  // --- INPUT FIELD WIDGET ---
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        style: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF3F2E5A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3F2E5A).withValues(alpha: 0.5), // FIXED
          ),
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF3F2E5A).withValues(alpha: 0.5), // FIXED
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  // --- PRIMARY BUTTON WIDGET ---
  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF98E4FF),
          foregroundColor: const Color(0xFF3F2E5A),
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
            color: const Color(0xFF3F2E5A),
          ),
        ),
      ),
    );
  }

  // --- SOCIAL BUTTON WIDGET ---
  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: const Color(0xFF3F2E5A)),
        label: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3F2E5A),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: const Color(0xFF3F2E5A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}