import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import 'child_settings_screen.dart';
import 'child_dashboard_screen.dart';

// TODO: Add rewards from firestore
// TODO: Update gold available at top to match users available gold
// TODO: Settings icon to go to settings page
// TODO: Back button goes to child dashboard

class ChildShopDashboardScreen extends ConsumerWidget {
  const ChildShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assuming you have a provider for the current child's ID
    // final childId = ref.watch(childUserProvider).id; 

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
                    const SizedBox(width: 40),
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
                        // Dynamic Gold Display from Firestore
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc('CURRENT_USER_ID') // Replace with dynamic ID
                              .snapshots(),
                          builder: (context, snapshot) {
                            final gold = snapshot.data?.get('total_points') ?? 0;
                            final name = snapshot.data?.get('display_name') ?? 'User';
                            return Text(
                              '$name 🥥 $gold Gold',
                              style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold),
                            );
                          },
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
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        'Rewards Shop',
                        style: AppTheme.bodyText(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      // Scrollable Rewards List from Firestore
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('rewards').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                            
                            final rewards = snapshot.data!.docs;

                            return ListView.builder(
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: rewards.length,
                              itemBuilder: (context, index) {
                                var reward = rewards[index];
                                return _buildRewardCard(
                                  context,
                                  reward['title'] ?? 'No Title',
                                  reward['description'] ?? '',
                                  reward['cost'].toString(),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
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

  Widget _buildRewardCard(BuildContext context, String title, String desc, String cost) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.electricSky,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.midnightPlum.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTheme.bodyText(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.videogame_asset, size: 40, color: AppTheme.midnightPlum),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  desc,
                  style: AppTheme.bodyText(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Buy for $cost Gold?',
                style: AppTheme.bodyText(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  // Logic for redemption request goes here
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}