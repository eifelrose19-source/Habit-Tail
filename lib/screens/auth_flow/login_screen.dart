import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTheme.screenWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Image.asset(
            'assets/images/icons/hbtletters.png',
            width: MediaQuery.of(context).size.width * 0.6,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: AppTheme.spacingXXL),

          // Email field
          TextField(
            decoration: AppTheme.textFieldDecoration(hint: 'Email'),
          ),

          const SizedBox(height: AppTheme.itemGap),

          // Password field
          TextField(
            obscureText: true,
            decoration: AppTheme.textFieldDecoration(hint: 'Password'),
          ),

          const SizedBox(height: AppTheme.spacingXXL),

          // Login button
          AppTheme.buildButton(
            label: 'Log In',
            onTap: () {
              // TODO: wire up auth
            },
          ),

          const SizedBox(height: AppTheme.itemGap),

          // Sign up link
          TextButton(
            onPressed: () {
              // TODO: navigate to signup
            },
            child: Text(
              "Don't have an account? Sign Up",
              style: AppTheme.linkText(),
            ),
          ),
        ],
      ),
    );
  }
}