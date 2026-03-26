import 'package:flutter/material.dart';
import 'package:habit_tail/theme/app_theme.dart';
import 'package:habit_tail/screens/auth/manage_family_screen.dart';
import 'package:habit_tail/screens/auth/join_family_screen.dart';

class CreateOrJoinFamilyScreen extends StatelessWidget {
  const CreateOrJoinFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTheme.screenWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // --- LOGO ---
          Image.asset('assets/images/icons/hbtletters.png', width: 300, fit: BoxFit.contain),

          const Spacer(flex: 3),

          // --- Create Family Button ---
          AppTheme.buildButton(
            context: context,
            label: "Create Family",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageFamilyScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // --- Join Family Button ---
          AppTheme.buildButton(
            context: context,
            label: "Join Family",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JoinFamilyScreen()),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}