import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Add your authentication logic here
      // await authProvider.signUp(_emailController.text.trim(), _passwordController.text);
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/create-or-join-family');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sign up failed: ${e.toString()}',
              style: GoogleFonts.quicksand(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              Color(0xFFD0BFFF), // Soft Iris
              Color(0xFFFFADBC), // Blush Pink
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Logo
                    Image.asset(
                      'assets/images/icons/hbtletters.png',
                      width: 200,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      'Create your account',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3F2E5A),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Email Input
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
                      validator: (value) =>
                          (value == null || !value.contains('@'))
                              ? 'Enter a valid email'
                              : null,
                    ),

                    const SizedBox(height: 24),

                    // Password Input
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
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Must be 6+ characters'
                          : null,
                    ),

                    const SizedBox(height: 24),

                    // Confirm Password Input
                    Text(
                      'Confirm Password:',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3F2E5A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      controller: _confirmPasswordController,
                      hint: '••••••••••••',
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                      validator: (value) =>
                          (value != _passwordController.text)
                              ? 'Passwords do not match'
                              : null,
                    ),

                    const SizedBox(height: 40),

                    // Sign Up Button
                    _buildPrimaryButton(
                      label: 'Sign Up',
                      onTap: _isLoading ? null : _handleSignUp,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 24),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3F2E5A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Log In',
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
      ),
    );
  }

  // Input Field Widget
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 52,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: GoogleFonts.quicksand(
            fontSize: 12,
            color: Colors.red,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF3F2E5A).withValues(alpha: 0.5), // FIXED
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  // Primary Button Widget
  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF98E4FF), // Electric Sky
          foregroundColor: const Color(0xFF3F2E5A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF3F2E5A),
                  strokeWidth: 2.5,
                ),
              )
            : Text(
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
}