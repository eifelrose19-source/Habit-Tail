import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../models/user_model.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class ParentSettingsScreen extends ConsumerWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final userName = user?.name ?? 'Parent';

    return AppTheme.parentScreenWrapper(
      child: Column(
        children: [
          _SettingsAppBar(userName: userName),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingL),
                  _ProfileSection(user: user),
                  const SizedBox(height: AppTheme.spacingM),
                  _PinSection(user: user),
                  const SizedBox(height: AppTheme.spacingM),
                  _GoldEconomySection(user: user),
                  const SizedBox(height: AppTheme.spacingM),
                  const _NotificationsSection(),
                  const SizedBox(height: AppTheme.spacingM),
                  _AccountSection(user: user),
                  const SizedBox(height: AppTheme.spacingL),
                  _SignOutButton(),
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

class _SettingsAppBar extends StatelessWidget {
  final String userName;
  const _SettingsAppBar({required this.userName});

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
          // Home — pops to root (parent dashboard)
          GestureDetector(
            onTap: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.home_outlined,
                    color: AppTheme.surface, size: 24),
                const SizedBox(height: 2),
                Text('Home',
                    style: AppTheme.caption(color: AppTheme.surface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Card Wrapper ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(color: AppTheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.sectionHeading()),
          const SizedBox(height: AppTheme.spacingM),
          ...children,
        ],
      ),
    );
  }
}

// ─── Settings Row ─────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
        decoration: AppTheme.cardDecoration(color: AppTheme.cardLight),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.midnightPlum, size: 20),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTheme.body()),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: AppTheme.caption(
                            color: AppTheme.midnightPlum
                                .withAlpha(150))),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(Icons.chevron_right,
                        color: AppTheme.midnightPlum, size: 20)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Section ──────────────────────────────────────────────────────────

class _ProfileSection extends StatelessWidget {
  final UserModel? user;
  const _ProfileSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Profile',
      children: [
        // Avatar display
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.electricSky,
              border: Border.all(color: AppTheme.softIris, width: 2),
            ),
            child: const Icon(Icons.person,
                color: AppTheme.midnightPlum, size: 40),
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),

        _SettingsRow(
          icon: Icons.edit_outlined,
          label: 'Edit Name',
          subtitle: user?.name,
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXL)),
            ),
            builder: (_) => _EditNameSheet(user: user),
          ),
        ),

        _SettingsRow(
          icon: Icons.email_outlined,
          label: 'Change Email',
          subtitle: FirebaseAuth.instance.currentUser?.email,
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXL)),
            ),
            builder: (_) => const _ChangeEmailSheet(),
          ),
        ),

        _SettingsRow(
          icon: Icons.lock_outline,
          label: 'Change Password',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXL)),
            ),
            builder: (_) => const _ChangePasswordSheet(),
          ),
        ),
      ],
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
    _nameController = TextEditingController(text: widget.user?.name ?? '');
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
    return _BottomSheetWrapper(
      title: 'Edit Name',
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: AppTheme.textFieldDecoration(hint: 'Display Name'),
            style: AppTheme.body(),
          ),
          const SizedBox(height: AppTheme.spacingL),
          _SheetSaveButton(isLoading: isLoading, onTap: _save),
        ],
      ),
    );
  }
}

// ─── Change Email Sheet ───────────────────────────────────────────────────────

class _ChangeEmailSheet extends StatefulWidget {
  const _ChangeEmailSheet();

  @override
  State<_ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends State<_ChangeEmailSheet> {
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not signed in');

      // Re-authenticate before changing email
      final credential = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: _passwordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(
          _newEmailController.text.trim());

      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Change Email',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration:
                AppTheme.textFieldDecoration(hint: 'Current Password'),
            style: AppTheme.body(),
          ),
          const SizedBox(height: AppTheme.spacingM),
          TextField(
            controller: _newEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: AppTheme.textFieldDecoration(hint: 'New Email'),
            style: AppTheme.body(),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(_error!,
                style: AppTheme.caption(color: AppTheme.statusRejected)),
          ],
          const SizedBox(height: AppTheme.spacingL),
          _SheetSaveButton(isLoading: _isLoading, onTap: _save),
        ],
      ),
    );
  }
}

// ─── Change Password Sheet ────────────────────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_newController.text != _confirmController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not signed in');

      final credential = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: _currentController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newController.text.trim());

      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Change Password',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _currentController,
            obscureText: true,
            decoration:
                AppTheme.textFieldDecoration(hint: 'Current Password'),
            style: AppTheme.body(),
          ),
          const SizedBox(height: AppTheme.spacingM),
          TextField(
            controller: _newController,
            obscureText: true,
            decoration:
                AppTheme.textFieldDecoration(hint: 'New Password'),
            style: AppTheme.body(),
          ),
          const SizedBox(height: AppTheme.spacingM),
          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration:
                AppTheme.textFieldDecoration(hint: 'Confirm New Password'),
            style: AppTheme.body(),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(_error!,
                style: AppTheme.caption(color: AppTheme.statusRejected)),
          ],
          const SizedBox(height: AppTheme.spacingL),
          _SheetSaveButton(isLoading: _isLoading, onTap: _save),
        ],
      ),
    );
  }
}

// ─── PIN Section ──────────────────────────────────────────────────────────────

class _PinSection extends StatelessWidget {
  final UserModel? user;
  const _PinSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Parental PIN',
      children: [
        _SettingsRow(
          icon: Icons.pin_outlined,
          label: 'Change PIN',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXL)),
            ),
            builder: (_) => _ChangePinSheet(user: user),
          ),
        ),
        _SettingsRow(
          icon: Icons.help_outline,
          label: 'Forgot PIN',
          subtitle: 'Re-authenticate via Google to reset',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXL)),
            ),
            builder: (_) => _ForgotPinSheet(user: user),
          ),
        ),
      ],
    );
  }
}

// ─── Change PIN Sheet ─────────────────────────────────────────────────────────

class _ChangePinSheet extends ConsumerStatefulWidget {
  final UserModel? user;
  const _ChangePinSheet({required this.user});

  @override
  ConsumerState<_ChangePinSheet> createState() => _ChangePinSheetState();
}

class _ChangePinSheetState extends ConsumerState<_ChangePinSheet> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _currentPinController.text.trim();
    final newPin = _newPinController.text.trim();

    if (current != widget.user?.parentalPin) {
      setState(() => _error = 'Incorrect current PIN');
      return;
    }
    if (newPin.isEmpty) {
      setState(() => _error = 'New PIN cannot be empty');
      return;
    }

    await ref.read(familyProvider.notifier).savePinForUser(
          widget.user!.userId,
          newPin,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(familyProvider).isLoading;
    return _BottomSheetWrapper(
      title: 'Change PIN',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _currentPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration:
                AppTheme.textFieldDecoration(hint: 'Current PIN'),
            style: AppTheme.body(),
          ),
          const SizedBox(height: AppTheme.spacingM),
          TextField(
            controller: _newPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: AppTheme.textFieldDecoration(hint: 'New PIN'),
            style: AppTheme.body(),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(_error!,
                style: AppTheme.caption(color: AppTheme.statusRejected)),
          ],
          const SizedBox(height: AppTheme.spacingL),
          _SheetSaveButton(isLoading: isLoading, onTap: _save),
        ],
      ),
    );
  }
}

// ─── Forgot PIN Sheet ─────────────────────────────────────────────────────────

class _ForgotPinSheet extends ConsumerStatefulWidget {
  final UserModel? user;
  const _ForgotPinSheet({required this.user});

  @override
  ConsumerState<_ForgotPinSheet> createState() => _ForgotPinSheetState();
}

class _ForgotPinSheetState extends ConsumerState<_ForgotPinSheet> {
  final _newPinController = TextEditingController();
  bool _isLoading = false;
  bool _reauthed = false;
  String? _error;

  @override
  void dispose() {
    _newPinController.dispose();
    super.dispose();
  }

  Future<void> _reauth() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception('Sign in cancelled');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.currentUser
          ?.reauthenticateWithCredential(credential);
      setState(() => _reauthed = true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNewPin() async {
    final pin = _newPinController.text.trim();
    if (pin.isEmpty || widget.user == null) return;
    await ref
        .read(familyProvider.notifier)
        .savePinForUser(widget.user!.userId, pin);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        _isLoading || ref.watch(familyProvider).isLoading;

    return _BottomSheetWrapper(
      title: 'Forgot PIN',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_reauthed) ...[
            Text(
              'Verify your identity via Google to reset your PIN.',
              style: AppTheme.body(),
            ),
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton(
              onPressed: isLoading ? null : _reauth,
              style: AppTheme.elevatedButtonStyle,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.midnightPlum))
                  : Text('Verify with Google',
                      style: AppTheme.buttonText()),
            ),
          ] else ...[
            Text('Identity verified. Set your new PIN.',
                style: AppTheme.body()),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: _newPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: AppTheme.textFieldDecoration(hint: 'New PIN'),
              style: AppTheme.body(),
            ),
            const SizedBox(height: AppTheme.spacingL),
            _SheetSaveButton(isLoading: isLoading, onTap: _saveNewPin),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(_error!,
                style: AppTheme.caption(color: AppTheme.statusRejected)),
          ],
        ],
      ),
    );
  }
}

// ─── Gold & Economy Section ───────────────────────────────────────────────────

class _GoldEconomySection extends StatelessWidget {
  final UserModel? user;
  const _GoldEconomySection({required this.user});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Gold & Economy',
      children: [
        _SettingsRow(
          icon: Icons.monetization_on_outlined,
          label: 'Default Gold Per Task',
          subtitle: 'Pre-fills points when creating a task',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXL)),
            ),
            builder: (_) => _DefaultGoldSheet(user: user),
          ),
        ),
        _SettingsRow(
          icon: Icons.account_balance_wallet_outlined,
          label: 'View Gold Balances',
          subtitle: 'See each child\'s current balance',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXL)),
            ),
            builder: (_) => const _GoldBalancesSheet(),
          ),
        ),
      ],
    );
  }
}

// ─── Default Gold Sheet ───────────────────────────────────────────────────────

class _DefaultGoldSheet extends ConsumerStatefulWidget {
  final UserModel? user;
  const _DefaultGoldSheet({required this.user});

  @override
  ConsumerState<_DefaultGoldSheet> createState() =>
      _DefaultGoldSheetState();
}

class _DefaultGoldSheetState extends ConsumerState<_DefaultGoldSheet> {
  final _goldController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _goldController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = int.tryParse(_goldController.text.trim());
    if (value == null || widget.user == null) return;
    setState(() => _isLoading = true);
    try {
      // Store default gold at family level in Firestore
      await FirebaseFirestore.instance
          .collection('families')
          .doc(widget.user!.familyId)
          .set({'defaultTaskGold': value}, SetOptions(merge: true));
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Default Gold Per Task',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _goldController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration:
                AppTheme.textFieldDecoration(hint: 'Default points (e.g. 100)'),
            style: AppTheme.body(),
          ),
          const SizedBox(height: AppTheme.spacingL),
          _SheetSaveButton(isLoading: _isLoading, onTap: _save),
        ],
      ),
    );
  }
}

// ─── Gold Balances Sheet ──────────────────────────────────────────────────────

class _GoldBalancesSheet extends ConsumerWidget {
  const _GoldBalancesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(familyMembersProvider);

    return _BottomSheetWrapper(
      title: 'Gold Balances',
      child: membersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.softIris),
        ),
        error: (_, __) => Text('Could not load members.',
            style: AppTheme.caption(color: AppTheme.statusRejected)),
        data: (members) {
          final children =
              members.where((m) => !m.isParent).toList();
          if (children.isEmpty) {
            return Text('No children in family.',
                style: AppTheme.body());
          }
          return Column(
            children: children.map((child) {
              return Container(
                margin:
                    const EdgeInsets.only(bottom: AppTheme.spacingS),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration:
                    AppTheme.cardDecoration(color: AppTheme.cardLight),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person,
                            color: AppTheme.midnightPlum, size: 20),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(child.name, style: AppTheme.body()),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: AppTheme.goldText, size: 16),
                        const SizedBox(width: 4),
                        Text('${child.totalPoints}',
                            style: AppTheme.goldAmount()
                                .copyWith(fontSize: 14)),
                        const SizedBox(width: AppTheme.spacingM),
                        // Reset gold button
                        GestureDetector(
                          onTap: () => _confirmReset(
                              context, ref, child),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingS,
                              vertical: AppTheme.spacingXS,
                            ),
                            decoration: AppTheme.pillDecoration(
                                color: AppTheme.blushPink),
                            child: Text('Reset',
                                style: AppTheme.caption(
                                    color: AppTheme.midnightPlum)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _confirmReset(
      BuildContext context, WidgetRef ref, UserModel child) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Reset ${child.name}\'s Gold?',
            style: AppTheme.h2()),
        content: Text(
          'This will set ${child.name}\'s balance to 0. This cannot be undone.',
          style: AppTheme.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.buttonText()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Reset by setting points to negative of current total
              final delta = -child.totalPoints;
              await ref
                  .read(userProvider.notifier)
                  .addPoints(child.userId, delta);
            },
            child: Text('Reset',
                style: AppTheme.buttonText(
                    color: AppTheme.statusRejected)),
          ),
        ],
      ),
    );
  }
}

// ─── Notifications Section ────────────────────────────────────────────────────

class _NotificationsSection extends StatefulWidget {
  const _NotificationsSection();

  @override
  State<_NotificationsSection> createState() =>
      _NotificationsSectionState();
}

class _NotificationsSectionState extends State<_NotificationsSection> {
  // TODO: Wire to a real notifications provider / FCM when ready
  bool _taskSubmission = false;
  bool _rewardRedemption = false;
  bool _petCare = false;

  Widget _toggleRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: AppTheme.cardDecoration(color: AppTheme.cardLight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.body()),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.softIris,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Notifications',
      children: [
        _toggleRow('Task submission alerts', _taskSubmission,
            (v) => setState(() => _taskSubmission = v)),
        _toggleRow('Reward redemption requests', _rewardRedemption,
            (v) => setState(() => _rewardRedemption = v)),
        _toggleRow('Pet care reminders', _petCare,
            (v) => setState(() => _petCare = v)),
      ],
    );
  }
}

// ─── Account Section ──────────────────────────────────────────────────────────

class _AccountSection extends StatelessWidget {
  final UserModel? user;
  const _AccountSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final isGoogleLinked = firebaseUser?.providerData
            .any((p) => p.providerId == 'google.com') ??
        false;

    return _SectionCard(
      title: 'Account',
      children: [
        // Linked account — display only
        _SettingsRow(
          icon: isGoogleLinked ? Icons.link : Icons.apple,
          label: isGoogleLinked
              ? 'Linked: Google'
              : 'Linked: Apple',
          subtitle: firebaseUser?.email,
          trailing: const SizedBox.shrink(),
        ),

        // Delete account
        _SettingsRow(
          icon: Icons.delete_forever_outlined,
          label: 'Delete Account',
          subtitle: 'Permanently wipes all family data',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusXL)),
            ),
            builder: (_) => _DeleteAccountSheet(user: user),
          ),
          trailing: const Icon(Icons.chevron_right,
              color: AppTheme.statusRejected, size: 20),
        ),
      ],
    );
  }
}

// ─── Delete Account Sheet ─────────────────────────────────────────────────────

class _DeleteAccountSheet extends ConsumerStatefulWidget {
  final UserModel? user;
  const _DeleteAccountSheet({required this.user});

  @override
  ConsumerState<_DeleteAccountSheet> createState() =>
      _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends ConsumerState<_DeleteAccountSheet> {
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  static const _confirmPhrase = 'DELETE';

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _deleteEverything() async {
    if (_confirmController.text.trim() != _confirmPhrase) {
      setState(() => _error = 'Type DELETE to confirm');
      return;
    }

    final user = widget.user;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = FirebaseFirestore.instance;
      final familyId = user.familyId;
      final batch = db.batch();

      // 1. Delete all family members (parents + children)
      final members = await db
          .collection('users')
          .where('family_id', isEqualTo: familyId)
          .get();
      for (final doc in members.docs) {
        batch.delete(doc.reference);
      }

      // 2. Delete all pets
      final pets = await db
          .collection('pets')
          .where('family_id', isEqualTo: familyId)
          .get();
      for (final doc in pets.docs) {
        batch.delete(doc.reference);
      }

      // 3. Delete all tasks
      final tasks = await db
          .collection('tasks')
          .where('family_id', isEqualTo: familyId)
          .get();
      for (final doc in tasks.docs) {
        batch.delete(doc.reference);
      }

      // 4. Delete all rewards
      final rewards = await db
          .collection('rewards')
          .where('family_id', isEqualTo: familyId)
          .get();
      for (final doc in rewards.docs) {
        batch.delete(doc.reference);
      }

      // 5. Delete all redemption logs
      final logs = await db
          .collection('redemption_log')
          .where('family_id', isEqualTo: familyId)
          .get();
      for (final doc in logs.docs) {
        batch.delete(doc.reference);
      }

      // 6. Delete family doc if it exists
      batch.delete(db.collection('families').doc(familyId));

      await batch.commit();

      // 7. Delete Firebase Auth account last
      await FirebaseAuth.instance.currentUser?.delete();

      // authProvider listener handles sign-out + routing automatically
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Delete Account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.statusRejected.withAlpha(20),
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                  color: AppTheme.statusRejected.withAlpha(80)),
            ),
            child: Text(
              '⚠️ This will permanently delete all family members, pets, tasks, rewards, and your account. This cannot be undone.',
              style:
                  AppTheme.body(color: AppTheme.statusRejected),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text('Type DELETE to confirm:', style: AppTheme.body()),
          const SizedBox(height: AppTheme.spacingS),
          TextField(
            controller: _confirmController,
            decoration:
                AppTheme.textFieldDecoration(hint: 'DELETE'),
            style: AppTheme.body(),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(_error!,
                style:
                    AppTheme.caption(color: AppTheme.statusRejected)),
          ],
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton(
            onPressed: _isLoading ? null : _deleteEverything,
            style: AppTheme.destructiveButtonStyle,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.statusRejected))
                : Text('Delete Everything',
                    style: AppTheme.buttonText(
                        color: AppTheme.statusRejected)),
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

// ─── Shared Sheet Helpers ─────────────────────────────────────────────────────

class _BottomSheetWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  const _BottomSheetWrapper({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingXL,
        AppTheme.spacingXL,
        AppTheme.spacingXL,
        MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingXL,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            Text(title, style: AppTheme.sectionHeading()),
            const SizedBox(height: AppTheme.spacingM),
            child,
          ],
        ),
      ),
    );
  }
}

class _SheetSaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _SheetSaveButton(
      {required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: AppTheme.elevatedButtonStyle,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppTheme.midnightPlum))
          : Text('Save Changes', style: AppTheme.buttonText()),
    );
  }
}