import 'package:flutter/material.dart';
import 'package:habit_tail/theme/app_theme.dart';
import 'package:habit_tail/screens/auth/login_screen.dart';
import 'package:habit_tail/screens/auth/signup_screen.dart';

class LoginOrCreateScreen extends StatelessWidget {
  const LoginOrCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTheme.screenWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          Image.asset('assets/images/icons/hbtletters.png', width: 300, fit: BoxFit.contain),

          const Spacer(flex: 3),

          AppTheme.buildButton(
            context: context,
            label: "LOG IN",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          AppTheme.buildButton(
            context: context,
            label: "CREATE ACCOUNT",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}