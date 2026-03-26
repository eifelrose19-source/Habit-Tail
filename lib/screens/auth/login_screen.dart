import 'package:flutter/material.dart';
import 'package:habit_tail/theme/app_theme.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme.screenWrapper(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // Logo
            Image.asset('assets/images/icons/hbtletters.png', width: 200, fit: BoxFit.contain),

            const SizedBox(height: 60),

            // Email input
            Text('Email:', style: AppTheme.bodyText(fontSize: 16)),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _emailController,
              hint: 'email@example.com',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 24),

            // Password input
            Text('Password:', style: AppTheme.bodyText(fontSize: 16)),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _passwordController,
              hint: '••••••••••••',
              isPassword: true,
            ),
            const SizedBox(height: 8),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to forgot password screen
                },
                child: Text('Forgot Password?', style: AppTheme.bodyText()),
              ),
            ),
            const SizedBox(height: 24),

            // Log In Button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : AppTheme.buildButton(
                    context: context,
                    label: 'Log In',
                    onTap: () async {
                      setState(() => _isLoading = true);
                      try {
                        await _authService.signUp(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, '/create-or-join-family');
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                  ),

            const SizedBox(height: 32),

            // OR Divider
            Row(
              children: [
                const Expanded(child: Divider(color: AppTheme.midnightPlum)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Or Log in with', style: AppTheme.bodyText()),
                ),
                const Expanded(child: Divider(color: AppTheme.midnightPlum)),
              ],
            ),

            const SizedBox(height: 24),

            // Google Sign In
            _buildSocialButton(
              label: 'Log in with Google',
              icon: Icons.g_mobiledata,
              onTap: () async {
                setState(() => _isLoading = true);
                try {
                  await _authService.signInWithGoogle();
                  if (!context.mounted) return;
                  Navigator.pushNamed(context, '/create-or-join-family');
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
            ),

            const SizedBox(height: 16),

            // Apple Sign In
            _buildSocialButton(
              label: 'Log in with Apple',
              icon: Icons.apple,
              onTap: () async {
                // TODO: Implement Apple Sign In
              },
            ),

            const SizedBox(height: 32),

            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ", style: AppTheme.bodyText()),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: Text(
                    'Sign Up',
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
    );
  }

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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.midnightPlum.withValues(alpha: 0.5),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Future<void> Function() onTap,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: AppTheme.midnightPlum),
        label: Text(label, style: AppTheme.buttonText()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.midnightPlum,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}