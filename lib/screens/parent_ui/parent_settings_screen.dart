import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../repositories/user_repository.dart';
import '../../models/user_model.dart';

class ParentSettingsScreen extends ConsumerStatefulWidget {
  const ParentSettingsScreen({super.key});

  @override
  ConsumerState<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends ConsumerState<ParentSettingsScreen> {
  double _defaultGoldValue = 0;
  bool _taskAlerts = true;
  bool _rewardAlerts = true;

  final UserRepository _userRepo = UserRepository();

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final currentUser = userState.user;

    if (userState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.beigeBackground,
      body: Column(
        children: [
          _buildHeader(context, currentUser),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionTitle('Profile'),
                  _buildProfileSection(context, currentUser),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Parental PIN'),
                  _buildPinSection(context, currentUser),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Gold & Economy'),
                  _buildGoldSection(context, currentUser),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Notifications'),
                  _buildNotificationsSection(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Account'),
                  _buildAccountSection(context, currentUser),
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

  Widget _buildHeader(BuildContext context, UserModel? user) {
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
              Text('${user?.displayName ?? 'Parent'}!', 
                style: AppTheme.bodyText(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Column(
              children: [
                const Icon(Icons.home, color: AppTheme.midnightPlum, size: 28),
                Text('Home', style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, UserModel? user) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'No email found';
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.electricSky.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(
              color: AppTheme.softIris,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.person, color: AppTheme.midnightPlum, size: 35),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.displayName ?? 'User',
                    style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(email, style: AppTheme.bodyText(fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showEditProfileDialog(context, user),
            style: AppTheme.elevatedButtonStyle,
            child: Text('Edit', style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldSection(BuildContext context, UserModel? user) {
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
              Text('Default Gold per Task:', style: AppTheme.bodyText(fontSize: 13, fontWeight: FontWeight.bold)),
              Text('${_defaultGoldValue.round()} Gold',
                  style: AppTheme.bodyText(fontSize: 13, fontWeight: FontWeight.bold).copyWith(color: Colors.orange)),
            ],
          ),
          Slider(
            value: _defaultGoldValue,
            min: 0, max: 500, divisions: 50,
            activeColor: AppTheme.softIris,
            onChanged: (value) => setState(() => _defaultGoldValue = value),
          ),
          const Divider(color: AppTheme.softIris),
          _buildSettingsRow(
            icon: Icons.monetization_on,
            label: 'View Gold Balances',
            onTap: () => _showGoldBalancesModal(context, user?.familyId),
          ),
          const Divider(color: AppTheme.softIris),
          _buildSettingsRow(
            icon: Icons.refresh,
            label: 'Reset a Child\'s Gold Balance',
            onTap: () => _showResetGoldModal(context, user?.familyId),
          ),
        ],
      ),
    );
  }

  void _showGoldBalancesModal(BuildContext context, String? familyId) async {
    if (familyId == null) return;
    final children = await _userRepo.getFamilyChildren(familyId);

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Gold Balances', style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (children.isEmpty)
              const Text("No family members found.")
            else
              ...children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(child.displayName, style: AppTheme.bodyText(fontWeight: FontWeight.bold)),
                    Text('${child.totalPoints} Gold', style: const TextStyle(color: Colors.orange)),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  void _showResetGoldModal(BuildContext context, String? familyId) async {
    if (familyId == null) return;
    final children = await _userRepo.getFamilyChildren(familyId);

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reset Gold Balance', style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ...children.map((child) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: AppTheme.buildButton(
                context: modalContext,
                label: 'Reset ${child.displayName}',
                onTap: () => _showConfirmResetDialog(context, child),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showConfirmResetDialog(BuildContext context, UserModel child) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Reset ${child.displayName}\'s Gold?'),
        content: Text('This will set gold to 0 for ${child.displayName}. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _userRepo.updateUser(child.userId, {'total_points': 0});
              if (!context.mounted) return;
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserModel? user) {
    final nameController = TextEditingController(text: user?.displayName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Display Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (user != null) {
                await _userRepo.updateUser(user.userId, {'display_name': nameController.text});
                ref.invalidate(userProvider);
              }
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppTheme.electricSky.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(15)),
      child: Column(children: [
        _buildToggleRow(label: 'Task Submission Alerts', value: _taskAlerts, onChanged: (v) => setState(() => _taskAlerts = v)),
        const Divider(color: AppTheme.softIris),
        _buildToggleRow(label: 'Reward Redemption Requests', value: _rewardAlerts, onChanged: (v) => setState(() => _rewardAlerts = v)),
      ]),
    );
  }

  Widget _buildAccountSection(BuildContext context, UserModel? user) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'Unknown';
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppTheme.electricSky.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(15)),
      child: _buildSettingsRow(icon: Icons.link, label: 'Linked Account', trailing: Text(email, style: AppTheme.bodyText(fontSize: 11))),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.irisLight, AppTheme.softIris])),
      child: Row(children: [
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        const SizedBox(width: 15),
        Expanded(child: AppTheme.buildButton(context: context, label: 'Sign Out', onTap: () async {
          await FirebaseAuth.instance.signOut();
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
        })),
      ]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
      const Divider(color: AppTheme.softIris, thickness: 1.5),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildSettingsRow({required IconData icon, required String label, VoidCallback? onTap, Widget? trailing, Color? textColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(icon, color: textColor ?? AppTheme.midnightPlum, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTheme.bodyText(fontSize: 13).copyWith(color: textColor))),
          if (trailing != null) trailing,
          if (onTap != null) const Icon(Icons.chevron_right, size: 20),
        ]),
      ),
    );
  }

  Widget _buildToggleRow({required String label, required bool value, required ValueChanged<bool> onChanged}) {
    return Row(children: [
      Expanded(child: Text(label, style: AppTheme.bodyText(fontSize: 13))),
      Switch(value: value, onChanged: onChanged, activeThumbColor: AppTheme.softIris),
    ]);
  }

  Widget _buildPinSection(BuildContext context, UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppTheme.electricSky.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(15)),
      child: _buildSettingsRow(icon: Icons.lock, label: 'Change PIN', onTap: () {}),
    );
  }
}