import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email.',
              style: AppTheme.caption(color: AppTheme.surface)),
          backgroundColor: AppTheme.statusRejected,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).resetPassword(email);

      if (!mounted) return;

      // Show success then navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset email sent! Check your inbox.',
              style: AppTheme.caption(color: AppTheme.surface)),
          backgroundColor: AppTheme.statusCompleted,
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(),
              style: AppTheme.caption(color: AppTheme.surface)),
          backgroundColor: AppTheme.statusRejected,
        ),
      );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingXXL),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL),
                child: Text('Forgot Password', style: AppTheme.h2()),
              ),

              const Spacer(flex: 2),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/icons/hbtletters.png',
                  width: screenWidth * 0.65,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(flex: 2),

              // Instruction text
              Center(
                child: Text(
                  'Submit your email\nto reset password:',
                  textAlign: TextAlign.center,
                  style: AppTheme.sectionHeading(),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Email field
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  decoration: AppTheme.textFieldDecoration(
                      hint: 'email@email.com'),
                ),
              ),

              const SizedBox(height: AppTheme.itemGap),

              // Submit button
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.electricSky),
                        ),
                      )
                    : AppTheme.buildButton(
                        label: 'Submit',
                        onTap: _submitReset,
                      ),
              ),

              const Spacer(flex: 1),

              // Back arrow
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: AppTheme.midnightPlum),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}