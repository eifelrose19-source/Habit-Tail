import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/family_provider.dart';
import '../../models/user_model.dart';
import '../parent_ui/parent_dashboard_screen.dart';
import '../child_ui/child_dashboard_screen.dart';

class WhoAreYouScreen extends ConsumerStatefulWidget {
  final String familyId;
  final List<UserModel> availableSlots;

  const WhoAreYouScreen({
    super.key,
    required this.familyId,
    required this.availableSlots,
  });

  @override
  ConsumerState<WhoAreYouScreen> createState() => _WhoAreYouScreenState();
}

class _WhoAreYouScreenState extends ConsumerState<WhoAreYouScreen> {
  UserModel? _selectedSlot;
  bool _showPinEntry = false;
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes =
      List.generate(4, (_) => FocusNode());

  String get _pin => _pinControllers.map((c) => c.text).join();
  bool get _pinComplete => _pin.length == 4;

  @override
  void dispose() {
    for (final c in _pinControllers) c.dispose();
    for (final f in _pinFocusNodes) f.dispose();
    super.dispose();
  }

  void _resetSelection() {
    setState(() {
      _selectedSlot = null;
      _showPinEntry = false;
      for (final c in _pinControllers) c.clear();
    });
  }

  void _onPinDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _pinFocusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onPinBackspace(int index) {
    if (_pinControllers[index].text.isEmpty && index > 0) {
      _pinControllers[index - 1].clear();
      _pinFocusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  Future<void> _onSlotTapped(UserModel slot) async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text(
          'Are you ${slot.name}?',
          style: AppTheme.sectionHeading(),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: AppTheme.outlineButtonStyle.copyWith(
              minimumSize: WidgetStateProperty.all(
                const Size(120, AppTheme.tappableHeight),
              ),
            ),
            child: Text('Cancel', style: AppTheme.buttonText()),
          ),
          const SizedBox(width: AppTheme.itemGap),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: AppTheme.elevatedButtonStyle.copyWith(
              minimumSize: WidgetStateProperty.all(
                const Size(120, AppTheme.tappableHeight),
              ),
            ),
            child: Text("Yes, that's me!", style: AppTheme.buttonText()),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Proceed based on role
    setState(() {
      _selectedSlot = slot;
      _showPinEntry = slot.isParent;
      for (final c in _pinControllers) c.clear();
    });

    if (!slot.isParent) {
      _claimChildSlot(slot);
    }
  }

  Future<void> _claimChildSlot(UserModel slot) async {
    await ref.read(familyProvider.notifier).claimChildSlot(slot.userId);

    final error = ref.read(familyProvider).error;
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error,
              style: AppTheme.caption(color: AppTheme.surface)),
          backgroundColor: AppTheme.statusRejected,
        ),
      );
      _resetSelection();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ChildDashboardScreen()),
      (route) => false,
    );
  }

  Future<void> _claimParentSlot() async {
    if (!_pinComplete) return;

    final success = await ref
        .read(familyProvider.notifier)
        .claimParentSlot(
          slotDocId: _selectedSlot!.userId,
          familyId: widget.familyId,
          enteredPin: _pin,
        );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect PIN. Please try again.',
              style: AppTheme.caption(color: AppTheme.surface)),
          backgroundColor: AppTheme.statusRejected,
        ),
      );
      _resetSelection();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ParentDashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final familyState = ref.watch(familyProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingXXL),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL),
                child: Text('Who are you?', style: AppTheme.h2()),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/icons/hbtletters.png',
                  width: screenWidth * 0.65,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: AppTheme.spacingXXL),

              // Subtitle
              Center(
                child:
                    Text('Who are you?', style: AppTheme.sectionHeading()),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Slot list + PIN entry
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXL),
                  child: Column(
                    children: [
                      // Member slots
                      ...widget.availableSlots.map((slot) {
                        final isClaimed = slot.claimed;
                        final isSelected =
                            _selectedSlot?.userId == slot.userId;

                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppTheme.itemGap),
                          child: ElevatedButton(
                            onPressed: isClaimed
                                ? null
                                : () => _onSlotTapped(slot),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? AppTheme.blushPink
                                  : AppTheme.electricSky,
                              foregroundColor: AppTheme.midnightPlum,
                              disabledBackgroundColor:
                                  AppTheme.midnightPlum.withAlpha(60),
                              minimumSize: const Size(
                                  double.infinity, AppTheme.tappableHeight),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isClaimed
                                  ? '${slot.name} (Taken)'
                                  : slot.name,
                              style: AppTheme.buttonText(
                                color: isClaimed
                                    ? AppTheme.surface.withAlpha(120)
                                    : AppTheme.midnightPlum,
                              ),
                            ),
                          ),
                        );
                      }),

                      // Inline PIN entry for parent slot
                      if (_showPinEntry && _selectedSlot != null) ...[
                        const SizedBox(height: AppTheme.spacingL),

                        Text(
                          'Enter Parental PIN to continue:',
                          style: AppTheme.body(),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppTheme.spacingL),

                        // 4 PIN boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            return Container(
                              width: 56,
                              height: 56,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingS),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium),
                                border: Border.all(
                                  color: _pinFocusNodes[index].hasFocus
                                      ? AppTheme.electricSky
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: TextField(
                                controller: _pinControllers[index],
                                focusNode: _pinFocusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                obscureText: true,
                                style: AppTheme.h2(),
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) =>
                                    _onPinDigitEntered(index, value),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: AppTheme.spacingL),

                        // Confirm + Cancel buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _resetSelection,
                                style: AppTheme.outlineButtonStyle,
                                child: Text('Cancel',
                                    style: AppTheme.buttonText()),
                              ),
                            ),
                            const SizedBox(width: AppTheme.itemGap),
                            Expanded(
                              child: familyState.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppTheme.electricSky),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _pinComplete
                                          ? _claimParentSlot
                                          : null,
                                      style: AppTheme.elevatedButtonStyle,
                                      child: Text('Confirm',
                                          style: AppTheme.buttonText()),
                                    ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: AppTheme.spacingXXL),
                    ],
                  ),
                ),
              ),

              // Back arrow
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: AppTheme.midnightPlum),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}