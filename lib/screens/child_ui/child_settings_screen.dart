import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../models/user_model.dart';

class ChildSettingsScreen extends ConsumerWidget {
  const ChildSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;

    return AppTheme.childScreenWrapper(
      child: Column(
        children: [
          _ChildSettingsAppBar(user: user),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingXL),
                  _ProfileCard(user: user),
                  const SizedBox(height: AppTheme.spacingM),
                  _FamilyIdCard(user: user),
                  const SizedBox(height: AppTheme.spacingXL),
                  _SignOutButton(),
                  const SizedBox(height: AppTheme.spacingL),
                  // Back button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: AppTheme.outlineButtonStyle,
                    child: Text('Back', style: AppTheme.buttonText()),
                  ),
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

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _ChildSettingsAppBar extends StatelessWidget {
  final UserModel? user;
  const _ChildSettingsAppBar({required this.user});

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
          // Logo
          Image.asset(
            'assets/images/icons/hbtletters.png',
            height: 36,
            errorBuilder: (_, __, ___) => Text(
              'HBT',
              style: AppTheme.h2(color: AppTheme.surface),
            ),
          ),

          // Name + gold
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                user?.name ?? 'Child',
                style: AppTheme.body(color: AppTheme.surface),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on,
                      color: AppTheme.goldText, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '${user?.totalPoints ?? 0} Gold',
                    style: AppTheme.goldAmount(),
                  ),
                ],
              ),
            ],
          ),

          // Spacer to balance layout
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ─── Profile Card ─────────────────────────────────────────────────────────────

class _ProfileCard extends ConsumerWidget {
  final UserModel? user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(color: AppTheme.surface),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.electricSky,
              border: Border.all(color: AppTheme.softIris, width: 2),
            ),
            child: const Icon(
              Icons.person,
              color: AppTheme.midnightPlum,
              size: 40,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),

          // Name
          Text(
            user?.name ?? '—',
            style: AppTheme.h2(),
          ),

          // Gold balance
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on,
                  color: AppTheme.goldText, size: 16),
              const SizedBox(width: 4),
              Text(
                '${user?.totalPoints ?? 0} Gold',
                style: AppTheme.goldAmount(),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),

          // Edit name button
          ElevatedButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppTheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusXL)),
              ),
              builder: (_) => _EditNameSheet(user: user),
            ),
            style: AppTheme.elevatedButtonStyle,
            child: Text('Edit Name', style: AppTheme.buttonText()),
          ),
        ],
      ),
    );
  }
}

// ─── Edit Name Sheet ──────────────────────────────────────────────────────────

class _EditNameSheet extends ConsumerStatefulWidget {
  final UserModel? user;
  const _EditNameSheet({required this.user});

  @override
  ConsumerState<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends ConsumerState<_EditNameSheet> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || widget.user == null) return;
    await ref
        .read(familyProvider.notifier)
        .renameMember(widget.user!.userId, name);
    if (mounted) Navigator.pop(context);
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.softIris,
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text('Edit Name', style: AppTheme.sectionHeading()),
          const SizedBox(height: AppTheme.spacingM),
          TextField(
            controller: _nameController,
            decoration:
                AppTheme.textFieldDecoration(hint: 'Your name'),
            style: AppTheme.body(),
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton(
            onPressed: isLoading ? null : _save,
            style: AppTheme.elevatedButtonStyle,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.midnightPlum))
                : Text('Save', style: AppTheme.buttonText()),
          ),
        ],
      ),
    );
  }
}

// ─── Family ID Card ───────────────────────────────────────────────────────────

class _FamilyIdCard extends StatelessWidget {
  final UserModel? user;
  const _FamilyIdCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final familyId = user?.familyId ?? '—';

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(color: AppTheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Family ID', style: AppTheme.sectionHeading()),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            '#$familyId',
            style: AppTheme.body(),
          ),
        ],
      ),
    );
  }
}

// ─── Sign Out Button ──────────────────────────────────────────────────────────

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authProvider).isLoading;

    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () => ref.read(authProvider.notifier).signOut(),
      style: AppTheme.destructiveButtonStyle,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppTheme.midnightPlum))
          : Text('Sign Out', style: AppTheme.buttonText()),
    );
  }
}