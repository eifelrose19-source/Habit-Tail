import 'package:flutter/material.dart';
import 'package:habit_tail/theme/app_theme.dart';

class WhoAreYouScreen extends StatelessWidget {
  final String partnerName;
  final String child1Name;
  final String child2Name;
  final String child3Name;

  const WhoAreYouScreen({
    super.key,
    required this.partnerName,
    required this.child1Name,
    required this.child2Name,
    required this.child3Name,
  });

  @override
  Widget build(BuildContext context) {
    return AppTheme.screenWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          Text('Who are you?', textAlign: TextAlign.center,
              style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.w600)),

          const SizedBox(height: 24),

          Image.asset('assets/images/icons/hbtletters.png', width: 250, fit: BoxFit.contain),

          const SizedBox(height: 32),

          AppTheme.buildButton(
            context: context,
            label: partnerName,
            onTap: () {
              // Navigate to parent dashboard
            },
          ),
          const SizedBox(height: 16),

          AppTheme.buildButton(
            context: context,
            label: child1Name,
            onTap: () {
              // Navigate to child 1 dashboard
            },
          ),
          const SizedBox(height: 16),

          AppTheme.buildButton(
            context: context,
            label: child2Name,
            onTap: () {
              // Navigate to child 2 dashboard
            },
          ),
          const SizedBox(height: 16),

          AppTheme.buildButton(
            context: context,
            label: child3Name,
            onTap: () {
              // Navigate to child 3 dashboard
            },
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}