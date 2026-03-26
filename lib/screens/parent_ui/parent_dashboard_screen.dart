import 'package:flutter/material.dart';
import 'package:habit_tail/theme/app_theme.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  static const Color beigeBackground = Color(0xFFF0EAD6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Text('Pets Dashboard', style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildPetList(),

                  const SizedBox(height: 10),
                  const Icon(Icons.add_circle, color: AppTheme.softIris, size: 35),

                  const SizedBox(height: 30),

                  Text('Tasks Awaiting Review', style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildTaskItem("Task: Feed Pet", "Submitted by: Tommy", "+50 Gold"),
                  _buildTaskItem("Task: Feed Pet", "Submitted by: Tommy", "+50 Gold"),
                  _buildTaskItem("Task: Feed Pet", "Submitted by: Tommy", "+50 Gold"),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildManagementSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 25, right: 25),
      decoration: AppTheme.backgroundGradient,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome,', style: AppTheme.bodyText(fontSize: 18)),
              Text('Sandra!', style: AppTheme.bodyText(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              _buildHeaderIcon(Icons.group, "Family"),
              const SizedBox(width: 15),
              _buildHeaderIcon(Icons.settings, "Settings"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.midnightPlum, size: 28),
        Text(label, style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPetList() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPetCard("Rexy", Colors.orange),
        _buildPetCard("Buddy", Colors.black),
        _buildPetCard("Fido", Colors.brown),
      ],
    );
  }

  Widget _buildPetCard(String name, Color color) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.electricSky,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.pets, color: color), // TODO: Replace with image asset
          ),
          const SizedBox(height: 5),
          Text(name, style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, String subtitle, String reward) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.electricSky.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyText(fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTheme.bodyText(fontSize: 10)),
              ],
            ),
          ),
          Text(reward, style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold).copyWith(color: Colors.orange)),
          const SizedBox(width: 10),
          const Icon(Icons.cancel_outlined, color: AppTheme.softIris),
          const SizedBox(width: 5),
          const Icon(Icons.check_circle_outline, color: AppTheme.softIris),
        ],
      ),
    );
  }

  Widget _buildManagementSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.irisLight, AppTheme.softIris],
        ),
      ),
      child: Column(
        children: [
          Text('Management', style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildSmallButton("Manage Tasks")),
              const SizedBox(width: 15),
              Expanded(child: _buildSmallButton("Manage Rewards")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String label) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: AppTheme.electricSky,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(label, style: AppTheme.bodyText(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }
}