import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/family_provider.dart';
import '../../models/user_model.dart';
import '../parent_ui/parent_settings_screen.dart';

class FamilyDashboardScreen extends ConsumerWidget {
  const FamilyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final userName = userState.user?.name ?? 'Parent';

    return AppTheme.familyScreenWrapper(
      child: Column(
        children: [
          _FamilyAppBar(userName: userName),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppTheme.spacingL),
                  _FamilyMembersSection(),
                  const SizedBox(height: AppTheme.spacingL),
                  _FamilyIdSection(),
                  const SizedBox(height: AppTheme.spacingL),
                  _ActivityFeedSection(),
                  const SizedBox(height: AppTheme.spacingXXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _FamilyAppBar extends StatelessWidget {
  final String userName;
  const _FamilyAppBar({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXL,
        vertical: AppTheme.spacingM,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.softIris, AppTheme.midnightPlum],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios,
                color: AppTheme.surface, size: 20),
          ),
          Text(
            'Welcome,\n$userName!',
            textAlign: TextAlign.center,
            style: AppTheme.h2(color: AppTheme.surface),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ParentSettingsScreen()),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.settings_outlined,
                    color: AppTheme.surface, size: 24),
                const SizedBox(height: 2),
                Text('Settings', style: AppTheme.caption(color: AppTheme.surface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Family Members Section ───────────────────────────────────────────────────

class _FamilyMembersSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(familyMembersProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(color: AppTheme.surface),
      child: Column(
        children: [
          Text('Family Members', style: AppTheme.sectionHeading()),
          const SizedBox(height: AppTheme.spacingM),
          membersAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.softIris),
            ),
            error: (_, __) => Center(
              child: Text('Could not load members.',
                  style: AppTheme.caption(color: AppTheme.statusRejected)),
            ),
            data: (members) {
              if (members.isEmpty) {
                return Text('No family members yet.',
                    style: AppTheme.body());
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: members
                      .map((m) => _MemberAvatar(member: m))
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends ConsumerWidget {
  final UserModel member;
  const _MemberAvatar({required this.member});

  void _showMemberOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      builder: (_) => _MemberOptionsSheet(member: member),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showMemberOptions(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
        child: Column(
          children: [
            Container(
              width: AppTheme.petAvatarSize,
              height: AppTheme.petAvatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.electricSky,
                border: Border.all(color: AppTheme.softIris, width: 2),
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.midnightPlum,
                size: 36,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(member.name, style: AppTheme.petName()),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on,
                    color: AppTheme.goldText, size: 12),
                const SizedBox(width: 2),
                Text(
                  '${member.totalPoints}',
                  style: AppTheme.caption(color: AppTheme.midnightPlum),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Member Options Bottom Sheet ─────────────────────────────────────────────

class _MemberOptionsSheet extends ConsumerStatefulWidget {
  final UserModel member;
  const _MemberOptionsSheet({required this.member});

  @override
  ConsumerState<_MemberOptionsSheet> createState() =>
      _MemberOptionsSheetState();
}

class _MemberOptionsSheetState extends ConsumerState<_MemberOptionsSheet> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.member.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == widget.member.name) {
      setState(() => _isEditing = false);
      return;
    }
    await ref
        .read(familyProvider.notifier)
        .renameMember(widget.member.userId, newName);
    if (mounted) {
      setState(() => _isEditing = false);
      Navigator.pop(context);
    }
  }

  Future<void> _deleteMember() async {
    Navigator.pop(context); // close sheet first
    await ref
        .read(familyProvider.notifier)
        .removeMember(widget.member);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(familyProvider).isLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingXL,
        AppTheme.spacingXL,
        AppTheme.spacingXL,
        MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingXL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.softIris,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),

          // Member name heading
          Text(widget.member.name, style: AppTheme.h2()),
          Text(
            widget.member.isParent ? 'Parent' : 'Child',
            style: AppTheme.caption(color: AppTheme.midnightPlum),
          ),
          const SizedBox(height: AppTheme.spacingXL),

          // Edit name field (shown when editing)
          if (_isEditing) ...[
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: AppTheme.textFieldDecoration(hint: 'Enter new name'),
              style: AppTheme.body(),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isEditing = false),
                    style: AppTheme.outlineButtonStyle,
                    child: Text('Cancel', style: AppTheme.buttonText()),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveName,
                    style: AppTheme.elevatedButtonStyle,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.midnightPlum,
                            ),
                          )
                        : Text('Save', style: AppTheme.buttonText()),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Edit name option
            _SheetOption(
              icon: Icons.edit_outlined,
              label: 'Edit Name',
              onTap: () => setState(() => _isEditing = true),
            ),
            const SizedBox(height: AppTheme.spacingS),

            // Delete option
            _SheetOption(
              icon: Icons.delete_outline,
              label: 'Delete Profile',
              color: AppTheme.statusRejected,
              onTap: isLoading ? null : _deleteMember,
            ),
          ],
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    this.color = AppTheme.midnightPlum,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
        ),
        decoration: AppTheme.cardDecoration(color: AppTheme.cardLight),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppTheme.spacingM),
            Text(label, style: AppTheme.body(color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── Family ID Section ────────────────────────────────────────────────────────

class _FamilyIdSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId = ref.watch(userProvider).user?.familyId ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingM,
      ),
      decoration: AppTheme.cardDecoration(color: AppTheme.softIris),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Family ID', style: AppTheme.caption()),
                const SizedBox(height: 2),
                Text(
                  '#$familyId',
                  style: AppTheme.body(color: AppTheme.midnightPlum),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: familyId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Family ID copied!',
                    style: AppTheme.caption(color: AppTheme.surface),
                  ),
                  backgroundColor: AppTheme.midnightPlum,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: AppTheme.pillDecoration(color: AppTheme.electricSky),
              child: Text('Copy', style: AppTheme.buttonText()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Activity Feed Section ────────────────────────────────────────────────────

class _ActivityFeedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Wire to a real activity/feed stream provider when collection is built
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text('Recent Activity', style: AppTheme.sectionHeading())),
        const SizedBox(height: AppTheme.spacingM),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: AppTheme.cardDecoration(color: AppTheme.surface),
          child: Text(
            'Activity feed coming soon.',
            style: AppTheme.body(color: AppTheme.midnightPlum),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}