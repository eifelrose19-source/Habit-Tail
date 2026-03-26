import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tail/theme/app_theme.dart';
import 'package:habit_tail/screens/auth/manage_family_screen.dart';

class CreateParentalPin extends StatelessWidget {
  const CreateParentalPin({super.key});

  // Replace with actual generated PIN later
  static const String familyCode = "1234";

  @override
  Widget build(BuildContext context) {
    return AppTheme.screenWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Instructions Text
          Text(
            'Create your parental pin! Make sure to save and share with your partner! This pin enables secure account management',
            textAlign: TextAlign.center,
            style: AppTheme.bodyText(),
          ),

          const SizedBox(height: 24),

          // --- VISUAL PIN DISPLAY BOX ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: AppTheme.codeBoxDecoration(),
            child: Text(familyCode, style: AppTheme.codeText()),
          ),

          const SizedBox(height: 32),

          // --- LOGO ---
          Image.asset('assets/images/icons/hbtletters.png', width: 250, fit: BoxFit.contain),

          const Spacer(flex: 3),

          // --- CREATE PIN BUTTON ---
          AppTheme.buildButton(
            context: context,
            label: "Create Pin",
            onTap: () {
              final messenger = ScaffoldMessenger.of(context);
              Clipboard.setData(const ClipboardData(text: familyCode)).then((_) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text("Created Pin!"),
                    backgroundColor: AppTheme.midnightPlum,
                  ),
                );
              });
            },
          ),

          const SizedBox(height: 16),

          // --- MANAGE FAMILY BUTTON ---
          AppTheme.buildButton(
            context: context,
            label: "Create Family Members",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageFamilyScreen()),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}