import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tail/models/user_model.dart';
import 'package:habit_tail/providers/family_provider.dart';
import 'package:habit_tail/providers/user_provider.dart';
import 'package:habit_tail/services/user_service.dart';
import 'package:habit_tail/theme/app_theme.dart';

class FamilyDashboardScreen extends ConsumerStatefulWidget {
  const FamilyDashboardScreen({super.key});

  @override
  ConsumerState<FamilyDashboardScreen> createState() =>
      _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState
    extends ConsumerState<FamilyDashboardScreen> {
  final UserService _userService = UserService();

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(String displayName) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.only(top: 60, bottom: 20, left: 25, right: 25),
      decoration: AppTheme.backgroundGradient,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome,', style: AppTheme.bodyText(fontSize: 18)),
              Text(
                '$displayName!',
                style: AppTheme.bodyText(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.settings,
                  color: AppTheme.midnightPlum, size: 28),
              Text('Settings',
                  style: AppTheme.bodyText(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Family Members Section ───────────────────────────────────────────────

  Widget _buildFamilyMembersSection(
      List<UserModel> members, String familyId) {
    return Container(
      color: AppTheme.beigeBackground,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Family Members',
              style: AppTheme.bodyText(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: members
                .map((m) => _buildFamilyMemberCard(
                      m.displayName,
                      m.role == 'child' ? '${m.totalPoints} Gold' : null,
                      isParent: m.role == 'parent',
                    ))
                .toList(),
          ),
          const SizedBox(height: 15),
          _buildFamilyCodeSection(familyId),
        ],
      ),
    );
  }

  Widget _buildFamilyCodeSection(String familyId) {
    return Builder(
      builder: (context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.electricSky.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Family ID:',
                style: AppTheme.bodyText(
                    fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '"$familyId"',
                    style: AppTheme.bodyText(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: familyId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Family ID copied!',
                            style: AppTheme.bodyText(fontSize: 13)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: AppTheme.elevatedButtonStyle,
                  icon: const Icon(Icons.copy, size: 14),
                  label: Text('Copy',
                      style: AppTheme.bodyText(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMemberCard(String name, String? gold,
      {bool isParent = false}) {
    return Container(
      width: 75,
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
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.person,
                color: AppTheme.midnightPlum, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            textAlign: TextAlign.center,
            style: AppTheme.bodyText(
                fontSize: 11, fontWeight: FontWeight.bold),
          ),
          if (gold != null) ...[
            const SizedBox(height: 3),
            Text(
              gold,
              textAlign: TextAlign.center,
              style: AppTheme.bodyText(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Activity Feed ────────────────────────────────────────────────────────

  Widget _buildActivityFeedSection() {
    // TODO: Wire to activity_log Firestore collection once built
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text('Activity Feed',
              style: AppTheme.bodyText(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Today',
              style: AppTheme.bodyText(
                  fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildActivityItem(Icons.card_giftcard,
              'Reward: 30Mins Game Time', 'Redeemed by: Tommy', '2 mins ago'),
          _buildActivityItem(Icons.task_alt, 'Task: Feed Dog',
              'Completed by Tommy', '25 mins ago'),
          _buildActivityItem(Icons.person_add, 'Family Member Added',
              'Child: Sammy', '35 mins ago'),
          _buildActivityItem(Icons.add_circle_outline,
              'Task Created: Walk Dog', 'Created by: Sandra', '40 mins ago'),
          _buildActivityItem(Icons.edit, 'Task Edited: Walk Dog',
              'Task Edited by: Sandra', '2 Hours ago'),
          _buildActivityItem(Icons.star_outline,
              'Reward Created: 30Mins Game Time',
              'Reward Created by: Sandra', '18 Hours ago'),
          _buildActivityItem(Icons.pets, 'Pet Added: Fido',
              'Added by: Sandra', '20 Hours ago'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      IconData icon, String title, String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.midnightPlum, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTheme.bodyText(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTheme.bodyText(fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.access_time,
              color: AppTheme.midnightPlum, size: 16),
          const SizedBox(width: 4),
          Text(time, style: AppTheme.bodyText(fontSize: 10)),
        ],
      ),
    );
  }

  // ─── Bottom Bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar(
      BuildContext context, List<UserModel> members) {
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
            icon: const Icon(Icons.arrow_back,
                color: AppTheme.midnightPlum),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: AppTheme.buildButton(
              context: context,
              label: 'Manage Family',
              onTap: () => _showManageFamilyModal(context, members),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Manage Family Modal ──────────────────────────────────────────────────

  void _showManageFamilyModal(
      BuildContext context, List<UserModel> members) {
    final parent = ref.read(userProvider).user;
    final String parentUid = parent?.userId ?? '';
    final String familyId = parent?.familyId ?? '';
    final bool hasPartner =
        members.any((m) => m.role == 'parent' && m.userId != parentUid);
    final int childCount =
        members.where((m) => m.role == 'child').length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text('Manage Family',
                  style: AppTheme.bodyText(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            if (!hasPartner) ...[
              AppTheme.buildButton(
                context: modalContext,
                label: '+ Add Partner',
                onTap: () => _showAddMemberDialog(
                  modalContext,
                  isPartner: true,
                  familyId: familyId,
                  parentUid: parentUid,
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (childCount < 3) ...[
              AppTheme.buildButton(
                context: modalContext,
                label: '+ Add Child',
                onTap: () => _showAddMemberDialog(
                  modalContext,
                  isPartner: false,
                  familyId: familyId,
                  parentUid: parentUid,
                ),
              ),
              const SizedBox(height: 20),
            ],

            Text('Current Members',
                style: AppTheme.bodyText(
                    fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ...members.map(
              (m) => _buildManageMemberRow(
                modalContext,
                m,
                parentUid: parentUid,
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildManageMemberRow(
    BuildContext context,
    UserModel member, {
    required String parentUid,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.electricSky.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            member.role == 'parent'
                ? Icons.shield
                : Icons.child_care,
            color: AppTheme.midnightPlum,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.displayName,
                    style: AppTheme.bodyText(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                Text(
                  member.claimed ? 'Claimed' : 'Unclaimed',
                  style: AppTheme.bodyText(fontSize: 11).copyWith(
                    color: member.claimed
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit,
                color: AppTheme.midnightPlum, size: 20),
            onPressed: () =>
                _showEditMemberDialog(context, member),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline,
                color: Colors.redAccent, size: 20),
            onPressed: () => _showRemoveMemberDialog(
              context,
              member,
              parentUid: parentUid,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────

  void _showAddMemberDialog(
    BuildContext context, {
    required bool isPartner,
    required String familyId,
    required String parentUid,
  }) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isPartner ? 'Add Partner' : 'Add Child',
          style: AppTheme.bodyText(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText:
                isPartner ? 'Partner\'s name' : 'Child\'s name',
            hintStyle: AppTheme.bodyText(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: AppTheme.bodyText(fontSize: 14)),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              await _userService.addFamilyMember(
                name: name,
                isPartner: isPartner,
                familyId: familyId,
                parentUid: parentUid,
              );
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext); // close dialog
              Navigator.pop(dialogContext); // close modal
            },
            child: Text('Add',
                style: AppTheme.bodyText(
                    fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditMemberDialog(
      BuildContext context, UserModel member) {
    final nameController =
        TextEditingController(text: member.displayName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit Name',
            style: AppTheme.bodyText(
                fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: AppTheme.bodyText(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: AppTheme.bodyText(fontSize: 14)),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;
              await _userService.renameFamilyMember(
                  member.userId, newName);
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              Navigator.pop(dialogContext);
            },
            child: Text('Save',
                style: AppTheme.bodyText(
                    fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(
    BuildContext context,
    UserModel member, {
    required String parentUid,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove ${member.displayName}?',
            style: AppTheme.bodyText(
                fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
          member.claimed
              ? 'This will remove ${member.displayName} from the family and unlink their account.'
              : 'This will remove ${member.displayName} from the family.',
          style: AppTheme.bodyText(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: AppTheme.bodyText(fontSize: 14)),
          ),
          TextButton(
            onPressed: () async {
              await _userService.removeFamilyMember(
                member: member,
                parentUid: parentUid,
              );
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              Navigator.pop(dialogContext);
            },
            child: Text('Remove',
                style: AppTheme.bodyText(
                        fontSize: 14, fontWeight: FontWeight.bold)
                    .copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final parent = userState.user;
    final familyId = parent?.familyId ?? '';

    final familyAsync = ref.watch(familyMembersProvider);

    if (userState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.beigeBackground,
      body: familyAsync.when(
        loading: () => Column(
          children: [
            _buildHeader(parent?.displayName ?? '…'),
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
        error: (err, _) => Column(
          children: [
            _buildHeader(parent?.displayName ?? '…'),
            Expanded(
              child: Center(child: Text(err.toString())),
            ),
          ],
        ),
        data: (members) => Column(
          children: [
            _buildHeader(parent?.displayName ?? '…'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFamilyMembersSection(members, familyId),
                    _buildActivityFeedSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context, members),
          ],
        ),
      ),
    );
  }
}

