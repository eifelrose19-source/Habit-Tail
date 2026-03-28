import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tail/theme/app_theme.dart';

class FamilyDashboardScreen extends StatelessWidget {
  const FamilyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beigeBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFamilyMembersSection(),
                  _buildActivityFeedSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          Column(
            children: [
              Icon(Icons.settings, color: AppTheme.midnightPlum, size: 28),
              Text('Settings', style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMembersSection() {
    // TODO: Replace hardcoded family members and family ID with real data from Firestore
    // Query users collection where family_id matches current family and map to cards
    const String familyId = 'AqGv5xf5oXk3OOmnUqlM';
    return Container(
      color: AppTheme.beigeBackground,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Family Members',
              style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFamilyMemberCard('Parent\nDavid', null, isParent: true),
              _buildFamilyMemberCard('Tommy', '500 Gold'),
              _buildFamilyMemberCard('Sammy', '1500 Gold'),
              _buildFamilyMemberCard('Emily', '200 Gold'),
            ],
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.electricSky.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Family ID:',
                style: AppTheme.bodyText(fontSize: 13, fontWeight: FontWeight.bold)),
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
                      style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMemberCard(String name, String? gold, {bool isParent = false}) {
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
            child: Icon(Icons.person, color: AppTheme.midnightPlum, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            textAlign: TextAlign.center,
            style: AppTheme.bodyText(fontSize: 11, fontWeight: FontWeight.bold),
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

  Widget _buildActivityFeedSection() {
    // TODO: Replace hardcoded activity items with real data from Firestore
    // Query activity_log collection where family_id matches, ordered by timestamp desc
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text('Activity Feed',
              style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // TODO: Group activity items by date (Today, Yesterday, This Week)
          Text('Today', style: AppTheme.bodyText(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildActivityItem(Icons.card_giftcard, 'Reward: 30Mins Game Time', 'Redeemed by: Tommy', '2 mins ago'),
          _buildActivityItem(Icons.task_alt, 'Task: Feed Dog', 'Completed by Tommy', '25 mins ago'),
          _buildActivityItem(Icons.person_add, 'Family Member Added', 'Child: Sammy', '35 mins ago'),
          _buildActivityItem(Icons.add_circle_outline, 'Task Created: Walk Dog', 'Created by: Sandra', '40 mins ago'),
          _buildActivityItem(Icons.edit, 'Task Edited: Walk Dog', 'Task Edited by: Sandra', '2 Hours ago'),
          _buildActivityItem(Icons.star_outline, 'Reward Created: 30Mins Game Time', 'Reward Created by: Sandra', '18 Hours ago'),
          _buildActivityItem(Icons.pets, 'Pet Added: Fido', 'Added by: Sandra', '20 Hours ago'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String subtitle, String time) {
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
                Text(title, style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTheme.bodyText(fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.access_time, color: AppTheme.midnightPlum, size: 16),
          const SizedBox(width: 4),
          Text(time, style: AppTheme.bodyText(fontSize: 10)),
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
              label: 'Manage Family',
              onTap: () => _showManageFamilyModal(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showManageFamilyModal(BuildContext context) {
    // TODO: Replace hardcoded values with real Firestore data
    // hasPartner: check if a second user with role: parent exists in this family
    // childCount: count users with role: child in this family
    // members: list of all user documents in this family
    bool hasPartner = true;
    int childCount = 3;
    final List<Map<String, dynamic>> members = [
      {'name': 'David', 'role': 'parent', 'claimed': true},
      {'name': 'Tommy', 'role': 'child', 'claimed': true},
      {'name': 'Sammy', 'role': 'child', 'claimed': false},
      {'name': 'Emily', 'role': 'child', 'claimed': true},
    ];

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
                  style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            // Add Partner button - only show if no partner yet
            // TODO: Replace with real Firestore check - bool hasPartner = familyMembers.any((m) => m['role'] == 'parent')
            if (!hasPartner) ...[
              AppTheme.buildButton(
                context: modalContext,
                label: '+ Add Partner',
                onTap: () => _showAddMemberDialog(modalContext, isPartner: true),
              ),
              const SizedBox(height: 12),
            ],

            // Add Child button - only show if less than 3 children
            // TODO: Replace with real Firestore check - int childCount = familyMembers.where((m) => m['role'] == 'child').length
            if (childCount < 3) ...[
              AppTheme.buildButton(
                context: modalContext,
                label: '+ Add Child',
                onTap: () => _showAddMemberDialog(modalContext, isPartner: false),
              ),
              const SizedBox(height: 20),
            ],

            Text('Current Members',
                style: AppTheme.bodyText(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ...members.map((member) => _buildManageMemberRow(modalContext, member)),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildManageMemberRow(BuildContext context, Map<String, dynamic> member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.electricSky.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            member['role'] == 'parent' ? Icons.shield : Icons.child_care,
            color: AppTheme.midnightPlum,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member['name'],
                    style: AppTheme.bodyText(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(
                  member['claimed'] ? 'Claimed' : 'Unclaimed',
                  style: AppTheme.bodyText(fontSize: 11).copyWith(
                    color: member['claimed'] ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.midnightPlum, size: 20),
            onPressed: () => _showEditMemberDialog(context, member['name']),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
            onPressed: () => _showRemoveMemberDialog(context, member),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, {required bool isPartner}) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isPartner ? 'Add Partner' : 'Add Child',
          style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: isPartner ? 'Partner\'s name' : 'Child\'s name',
            hintStyle: AppTheme.bodyText(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.bodyText(fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Add member to Firestore
              // - Create new user document with role: parent/child, display_name, family_id, claimed: false
              // - Add new user's ID to parent's children_id array
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Add',
                style: AppTheme.bodyText(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditMemberDialog(BuildContext context, String currentName) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Name',
            style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: AppTheme.bodyText(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.bodyText(fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Update display_name in Firestore for this member's user document
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Save',
                style: AppTheme.bodyText(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${member['name']}?',
            style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
          member['claimed']
              ? 'This will remove ${member['name']} from the family and unlink their Google account.'
              : 'This will remove ${member['name']} from the family.',
          style: AppTheme.bodyText(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.bodyText(fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Remove member from Firestore
              // - If claimed: clear family_id and parent_id from their user document
              // - Remove their ID from parent's children_id array
              // - If unclaimed: delete their user document entirely
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Remove',
                style: AppTheme.bodyText(fontSize: 14, fontWeight: FontWeight.bold)
                    .copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}