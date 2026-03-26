import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tail/theme/app_theme.dart';
import 'package:habit_tail/screens/auth/manage_family_screen.dart';

class CreateFamilyCode extends StatefulWidget {
  const CreateFamilyCode({super.key});

  @override
  State<CreateFamilyCode> createState() => _CreateFamilyCodeState();
}

class _CreateFamilyCodeState extends State<CreateFamilyCode> {
  @override
  Widget build(BuildContext context) {
    // This is the family code variable I will later make dynamic
    const String familyCode = "FAM-8534";

    return AppTheme.screenWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Instructions Text
          Text(
            'Below is your family code! Copy and share with family to create your family account!',
            textAlign: TextAlign.center,
            style: AppTheme.bodyText(),
          ),

          const SizedBox(height: 24),

          // --- VISUAL CODE DISPLAY BOX ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: AppTheme.codeBoxDecoration(),
            child: Text(familyCode, style: AppTheme.codeText()),
          ),

          const SizedBox(height: 32),

          // --- LOGO ---
          Image.asset('assets/images/icons/hbtletters.png', width: 250, fit: BoxFit.contain),

          const Spacer(flex: 3),

          // --- COPY CODE BUTTON ---
          AppTheme.buildButton(
            context: context,
            label: "Copy Code",
            onTap: () {
              final messenger = ScaffoldMessenger.of(context);
              Clipboard.setData(const ClipboardData(text: familyCode)).then((_) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text("Family code copied to clipboard!"),
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