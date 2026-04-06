import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'child_dashboard_screen.dart';

class ChildSettingsScreen extends StatelessWidget {
  const ChildSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Habit\nTail',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PinkyCupid',
                            fontSize: 28,
                            color: Color(0xFFFFADBC),
                            height: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tommy 🥥 500 Gold',
                          style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.softIris,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Avatar and Display Name (Edit)
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 50, color: AppTheme.midnightPlum),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Tommy', style: AppTheme.bodyText(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.edit, size: 18, color: AppTheme.midnightPlum),
                          ],
                        ),
                        const SizedBox(height: 40),
                        
                        // Family Code (View Only)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Family Code', style: AppTheme.bodyText(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          decoration: AppTheme.codeBoxDecoration(),
                          child: Text(
                            'HT-9921',
                            style: AppTheme.codeText().copyWith(fontSize: 18),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Sign Out Button
                        AppTheme.buildButton(
                          context: context,
                          label: 'Sign Out',
                          onTap: () {
                            // Sign out logic
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Navigation Area
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD0BFFF),
                          foregroundColor: AppTheme.midnightPlum,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const ChildDashboardScreen()),
                          );
                        },
                        child: Text('Back', style: AppTheme.buttonText()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}