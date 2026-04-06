import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart'; 
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    // Call the reset logic from your AuthNotifier
    await ref.read(authProvider.notifier).resetPassword(email);

    // Check if an error was set in the state after the call
    final authState = ref.read(authProvider);

    if (mounted) {
      if (authState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.error!)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watching the provider ensures the widget rebuilds on state changes,
    // but we no longer assign it to an unused local variable.
    ref.watch(authProvider);

    return AppTheme.screenWrapper(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/icons/hbtletters.png',
              width: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            Text(
              'Submit your email\nto reset password:',
              textAlign: TextAlign.center,
              style: AppTheme.bodyText(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: AppTheme.codeBoxDecoration(),
              child: TextField(
                controller: _emailController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                style: AppTheme.bodyText(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'email@email.com',
                  hintStyle: AppTheme.bodyText(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ).copyWith(color: AppTheme.midnightPlum.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 30),
            AppTheme.buildButton(
              context: context,
              label: 'Submit',
              onTap: _handleReset,
            ),
          ],
        ),
      ),
    );
  }
}