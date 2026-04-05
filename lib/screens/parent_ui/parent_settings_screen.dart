import 'package:flutter/material.dart';
import 'package:habit_tail/theme/app_theme.dart';

class ParentSettingsScreen extends StatefulWidget {
  const ParentSettingsScreen({super.key});

  @override
  State<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends State<ParentSettingsScreen> {
  // TODO: Replace hardcoded values with real data from Firestore
  double _defaultGoldValue = 50;
  bool _taskAlerts = true;
  bool _rewardAlerts = true;
  bool _petCareAlerts = true;

  // TODO: Replace hardcoded children with real data from Firestore
  final List<Map<String, dynamic>> _children = [
    {'name': 'Tommy', 'gold': 500},
    {'name': 'Sammy', 'gold': 1500},
    {'name': 'Emily', 'gold': 200},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beigeBackground,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionTitle('Profile'),
                  _buildProfileSection(context),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Parental PIN'),
                  _buildPinSection(context),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Gold & Economy'),
                  _buildGoldSection(context),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Notifications'),
                  _buildNotificationsSection(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Account'),
                  _buildAccountSection(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // TODO: Replace 'Sandra' with real parent display_name from Firestore
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
          GestureDetector(
            onTap: () {
              // TODO: Navigate to Parent Dashboard
              Navigator.pop(context);
            },
            child: Column(
              children: [
                Icon(Icons.home, color: AppTheme.midnightPlum, size: 28),
                Text('Home', style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
        const Divider(color: AppTheme.softIris, thickness: 1.5),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.electricSky.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: AppTheme.softIris,
              borderRadius: BorderRadius.circular(50),
            ),
            // TODO: Replace with real avatar image from Firestore storage
            child: const Icon(Icons.person, color: AppTheme.midnightPlum, size: 35),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO: Replace with real display_name from Firestore
                Text('Sandra',
                    style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
                // TODO: Replace with real email from Firebase Auth
                Text('sandra@email.com', style: AppTheme.bodyText(fontSize: 12)),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => _showEditProfileDialog(context),
                style: AppTheme.elevatedButtonStyle,
                child: Text('Edit',
                    style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPinSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.electricSky.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildSettingsRow(
            icon: Icons.lock,
            label: 'Change PIN',
            onTap: () => _showChangePinDialog(context),
          ),
          const Divider(color: AppTheme.softIris),
          _buildSettingsRow(
            icon: Icons.lock_reset,
            label: 'Forgot PIN (re-authenticate via Google/Apple)',
            onTap: () {
              // TODO: Trigger Google/Apple re-authentication then allow PIN reset
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoldSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.electricSky.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Default Gold per Task:',
                  style: AppTheme.bodyText(fontSize: 13, fontWeight: FontWeight.bold)),
              Text('${_defaultGoldValue.round()} Gold',
                  style: AppTheme.bodyText(fontSize: 13, fontWeight: FontWeight.bold)
                      .copyWith(color: Colors.orange)),
            ],
          ),
          Slider(
            value: _defaultGoldValue,
            min: 0,
            max: 500,
            divisions: 50,
            activeColor: AppTheme.softIris,
            inactiveColor: AppTheme.irisLight,
            onChanged: (value) {
              setState(() => _defaultGoldValue = value);
              // TODO: Update default gold value in Firestore for this family
            },
          ),
          const Divider(color: AppTheme.softIris),
          _buildSettingsRow(
            icon: Icons.monetization_on,
            label: 'View Gold Balances',
            onTap: () => _showGoldBalancesModal(context),
          ),
          const Divider(color: AppTheme.softIris),
          _buildSettingsRow(
            icon: Icons.refresh,
            label: 'Reset a Child\'s Gold Balance',
            onTap: () => _showResetGoldModal(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.electricSky.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildToggleRow(
            label: 'Task Submission Alerts',
            value: _taskAlerts,
            onChanged: (val) {
              setState(() => _taskAlerts = val);
              // TODO: Update notification preference in Firestore
              // TODO: Toggle push notification subscription for task events
            },
          ),
          const Divider(color: AppTheme.softIris),
          _buildToggleRow(
            label: 'Reward Redemption Requests',
            value: _rewardAlerts,
            onChanged: (val) {
              setState(() => _rewardAlerts = val);
              // TODO: Update notification preference in Firestore
              // TODO: Toggle push notification subscription for reward events
            },
          ),
          const Divider(color: AppTheme.softIris),
          _buildToggleRow(
            label: 'Pet Care Reminders',
            value: _petCareAlerts,
            onChanged: (val) {
              setState(() => _petCareAlerts = val);
              // TODO: Update notification preference in Firestore
              // TODO: Toggle push notification subscription for pet care events
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.electricSky.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildSettingsRow(
            icon: Icons.link,
            label: 'Linked Google/Apple Account',
            // TODO: Show linked account email from Firebase Auth
            trailing: Text('sandra@gmail.com',
                style: AppTheme.bodyText(fontSize: 11)),
            onTap: null,
          ),
          const Divider(color: AppTheme.softIris),
          _buildSettingsRow(
            icon: Icons.delete_forever,
            label: 'Delete Account',
            textColor: Colors.redAccent,
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? AppTheme.midnightPlum, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: AppTheme.bodyText(fontSize: 13).copyWith(color: textColor)),
            ),
            if (trailing != null) trailing,
            if (onTap != null)
              Icon(Icons.chevron_right, color: AppTheme.midnightPlum, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTheme.bodyText(fontSize: 13)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.softIris,
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    // TODO: Pre-fill with real display_name and email from Firestore/Firebase Auth
    final TextEditingController nameController = TextEditingController(text: 'Sandra');
    final TextEditingController emailController =
        TextEditingController(text: 'sandra@email.com');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile',
            style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                labelStyle: AppTheme.bodyText(fontSize: 13),
              ),
              style: AppTheme.bodyText(fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: AppTheme.bodyText(fontSize: 13),
              ),
              style: AppTheme.bodyText(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.bodyText(fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Update display_name in Firestore and email in Firebase Auth
              Navigator.pop(context);
            },
            child: Text('Save',
                style: AppTheme.bodyText(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context) {
    final TextEditingController oldPinController = TextEditingController();
    final TextEditingController newPinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change PIN',
            style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Current PIN',
                labelStyle: AppTheme.bodyText(fontSize: 13),
              ),
              style: AppTheme.bodyText(fontSize: 13),
            ),
            TextField(
              controller: newPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'New PIN',
                labelStyle: AppTheme.bodyText(fontSize: 13),
              ),
              style: AppTheme.bodyText(fontSize: 13),
            ),
            TextField(
              controller: confirmPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Confirm New PIN',
                labelStyle: AppTheme.bodyText(fontSize: 13),
              ),
              style: AppTheme.bodyText(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.bodyText(fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Verify old PIN matches parentalPin in Firestore
              // TODO: Verify newPin == confirmPin
              // TODO: Update parentalPin in Firestore with new PIN
              Navigator.pop(context);
            },
            child: Text('Save',
                style: AppTheme.bodyText(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showGoldBalancesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Gold Balances',
                style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // TODO: Replace with real children gold balances from Firestore
            ..._children.map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.child_care,
                              color: AppTheme.midnightPlum, size: 20),
                          const SizedBox(width: 10),
                          Text(child['name'],
                              style: AppTheme.bodyText(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text('${child['gold']} Gold',
                          style: AppTheme.bodyText(fontSize: 14)
                              .copyWith(color: Colors.orange)),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showResetGoldModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reset Gold Balance',
                style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Select a child to reset their gold to 0:',
                style: AppTheme.bodyText(fontSize: 13)),
            const SizedBox(height: 15),
            // TODO: Replace with real children from Firestore
            ..._children.map((child) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: AppTheme.buildButton(
                    context: modalContext,
                    label: 'Reset ${child['name']} (${child['gold']} Gold)',
                    onTap: () => _showConfirmResetDialog(modalContext, child),
                  ),
                )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showConfirmResetDialog(BuildContext context, Map<String, dynamic> child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset ${child['name']}\'s Gold?',
            style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
          'This will reset ${child['name']}\'s gold balance from ${child['gold']} to 0. This cannot be undone.',
          style: AppTheme.bodyText(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.bodyText(fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Update total_points to 0 for this child's user document in Firestore
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Reset',
                style: AppTheme.bodyText(fontSize: 14, fontWeight: FontWeight.bold)
                    .copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account?',
            style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)
                .copyWith(color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 40),
            const SizedBox(height: 10),
            Text(
              '⚠️ WARNING: This will permanently delete your entire family account including:',
              style: AppTheme.bodyText(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• All family members', style: AppTheme.bodyText(fontSize: 13)),
            Text('• All pets and tasks', style: AppTheme.bodyText(fontSize: 13)),
            Text('• All rewards and gold balances', style: AppTheme.bodyText(fontSize: 13)),
            Text('• All activity history', style: AppTheme.bodyText(fontSize: 13)),
            const SizedBox(height: 8),
            Text('This action cannot be undone.',
                style: AppTheme.bodyText(fontSize: 13, fontWeight: FontWeight.bold)
                    .copyWith(color: Colors.redAccent)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.bodyText(fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Delete entire family from Firestore:
              // - Delete all documents in users collection with this family_id
              // - Delete all documents in pets collection with this family_id
              // - Delete all documents in tasks collection with this family_id
              // - Delete all documents in rewards collection with this family_id
              // - Delete all documents in redemption_log with this family_id
              // - Delete Firebase Auth accounts for all family members
              Navigator.pop(context);
            },
            child: Text('Delete Everything',
                style: AppTheme.bodyText(fontSize: 14, fontWeight: FontWeight.bold)
                    .copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.irisLight, AppTheme.softIris],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppTheme.midnightPlum),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: AppTheme.buildButton(
              context: context,
              label: 'Sign Out',
              onTap: () {
                // TODO: Sign out from Firebase Auth and navigate to login screen
              },
            ),
          ),
        ],
      ),
    );
  }
}