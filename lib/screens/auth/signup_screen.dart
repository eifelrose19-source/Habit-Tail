import 'package:flutter/material.dart';
import 'package:habit_tail/theme/app_theme.dart';
import '../../services/auth_service.dart';

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
  final _authService = AuthService();
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
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/create-or-join-family');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign up failed: ${e.toString()}', style: AppTheme.bodyText()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme.screenWrapper(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/icons/hbtletters.png', width: 200, fit: BoxFit.contain),
              const SizedBox(height: 40),

              Text('Create your account', textAlign: TextAlign.center,
                  style: AppTheme.bodyText(fontSize: 24, fontWeight: FontWeight.w600)),
              const SizedBox(height: 40),

              Text('Email:', style: AppTheme.bodyText(fontSize: 16)),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _emailController,
                hint: 'email@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 24),

              Text('Password:', style: AppTheme.bodyText(fontSize: 16)),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _passwordController,
                hint: '••••••••••••',
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: (value) =>
                    (value == null || value.length < 6) ? 'Must be 6+ characters' : null,
              ),
              const SizedBox(height: 24),

              Text('Confirm Password:', style: AppTheme.bodyText(fontSize: 16)),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _confirmPasswordController,
                hint: '••••••••••••',
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () =>
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (value) =>
                    (value != _passwordController.text) ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 40),

              // Sign Up Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: AppTheme.elevatedButtonStyle,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.midnightPlum, strokeWidth: 2.5,
                          ),
                        )
                      : Text('Sign Up', style: AppTheme.buttonText()),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: AppTheme.bodyText()),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Log In',
                      style: AppTheme.bodyText(fontWeight: FontWeight.bold).copyWith(
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
    );
  }

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
        style: AppTheme.bodyText(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.bodyText(fontSize: 16).copyWith(
            color: AppTheme.midnightPlum.withValues(alpha: 0.5),
          ),
          filled: true,
          fillColor: Colors.white,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: AppTheme.bodyText(fontSize: 12).copyWith(color: Colors.red),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.midnightPlum.withValues(alpha: 0.5),
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}