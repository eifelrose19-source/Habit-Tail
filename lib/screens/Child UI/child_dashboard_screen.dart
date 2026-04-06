import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'child_shop_dashboard_screen.dart';
import 'child_settings_screen.dart';

class ChildDashboardScreen extends StatelessWidget {
  const ChildDashboardScreen({super.key});

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40), // Spacing for balance
                    Column(
                      children: [
                        Text(
                          'Habit\nTail',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            fontSize: 28,
                            color: const Color(0xFFFFADBC),
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
                    IconButton(
                      icon: const Icon(Icons.settings, color: AppTheme.midnightPlum),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChildSettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppTheme.softIris,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        Text(
                          'Assigned Pets',
                          style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        // Pets Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPetCard('Rexy', 'assets/images/rexy.png'),
                            const SizedBox(width: 20),
                            _buildPetCard('Tim', 'assets/images/tim.png'),
                          ],
                        ),
                        const SizedBox(height: 25),
                        // Tasks List
                        _buildTaskTile('Task: Feed Rexy', 'Due: Today', '+50 Gold'),
                        _buildTaskTile('Task: Feed Rexy', 'Due: Today', '+50 Gold'),
                        _buildTaskTile('Task: Feed Rexy', 'Due: Today', '+50 Gold'),
                        _buildTaskTile('Task: Feed Rexy', 'Due: Today', '+50 Gold'),
                        _buildTaskTile('Task: Feed Rexy', 'Due: Today', '+50 Gold'),
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
                    // Streak Banner (Not a button)
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.electricSky,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '3 Day Streak!',
                          style: AppTheme.buttonText(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Shop Button
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: AppTheme.elevatedButtonStyle,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChildShopDashboardScreen()),
                            );
                          },
                          child: Text('Shop', style: AppTheme.buttonText()),
                        ),
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

  Widget _buildPetCard(String name, String imagePath) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
            boxShadow: [
              BoxShadow(
                color: AppTheme.midnightPlum.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(name, style: AppTheme.bodyText(fontSize: 12)),
      ],
    );
  }

  Widget _buildTaskTile(String title, String subtitle, String reward) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.electricSky,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.midnightPlum.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyText(fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTheme.bodyText(fontSize: 12)),
              ],
            ),
          ),
          Text(
            reward,
            style: AppTheme.bodyText(fontWeight: FontWeight.bold, fontSize: 14)
                .copyWith(color: Colors.orange[800]),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFFFADBC), // blushPink
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}