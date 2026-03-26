import 'package:flutter/material.dart';
import 'package:habit_tail/theme/app_theme.dart';

class JoinFamilyScreen extends StatelessWidget {
  const JoinFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTheme.screenWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(backgroundColor: Colors.transparent, elevation: 0),

          Text(
            "Enter your family code below to join your family",
            style: AppTheme.bodyText(fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            "Enter the unique Family ID provided by your parent.",
            style: AppTheme.bodyText(),
          ),

          const SizedBox(height: 32),

          TextField(
            decoration: InputDecoration(
              labelText: "Family ID (e.g., FAM-123)",
              labelStyle: AppTheme.bodyText(),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 24),

          AppTheme.buildButton(
            context: context,
            label: "Find My Family",
            onTap: () {
              // Logic to search DB for Family ID
            },
          ),
        ],
      ),
    );
  }
}