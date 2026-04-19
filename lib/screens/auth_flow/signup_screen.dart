import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'createorjoin_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTheme.caption(color: AppTheme.surface)),
        backgroundColor: AppTheme.statusRejected,
      ),
    );
  }

  void _navigateToCreateOrJoin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CreateOrJoinScreen()),
    );
  }

  Future<void> _signUpWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signUp(email, password);
      if (mounted) _navigateToCreateOrJoin();
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (mounted) _navigateToCreateOrJoin();
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spacingXXL),

                // Title
                Text('Sign Up', style: AppTheme.h2()),

                const SizedBox(height: AppTheme.spacingL),

                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/icons/hbtletters.png',
                    width: screenWidth * 0.65,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXXL),

                // Email field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppTheme.textFieldDecoration(hint: 'Email'),
                ),

                const SizedBox(height: AppTheme.itemGap),

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: AppTheme.textFieldDecoration(
                    hint: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.midnightPlum,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Terms text
                Center(
                  child: Text(
                    'By signing up, you agree to our\nTerms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: AppTheme.caption(
                        color: AppTheme.midnightPlum.withAlpha(180)),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Sign Up button
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.electricSky),
                        ),
                      )
                    : AppTheme.buildButton(
                        label: 'Sign Up',
                        onTap: _signUpWithEmail,
                      ),

                const SizedBox(height: AppTheme.spacingXL),

                // Divider
                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: AppTheme.midnightPlum)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM),
                      child: Text('Or Sign up with',
                          style: AppTheme.caption()),
                    ),
                    const Expanded(
                        child: Divider(color: AppTheme.midnightPlum)),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Google button
                _isLoading
                    ? const SizedBox.shrink()
                    : _GoogleSignUpButton(onTap: _signUpWithGoogle),

                const SizedBox(height: AppTheme.spacingXL),

                // Already have account
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: AppTheme.caption(),
                        children: [
                          TextSpan(
                            text: 'Log in',
                            style: AppTheme.linkText(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignUpButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleSignUpButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppTheme.tappableHeight,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.electricSky, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.google.com/favicon.ico',
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.g_mobiledata,
                size: 24,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Text('Sign in with Google', style: AppTheme.buttonText()),
          ],
        ),
      ),
    );
  }
}