import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/family_provider.dart';
import '../../providers/auth_provider.dart';
import '../parent_ui/parent_dashboard_screen.dart';

class ManageFamilyScreen extends ConsumerStatefulWidget {
  final String parentalPin;
  final String familyCode;

  const ManageFamilyScreen({
    super.key,
    required this.parentalPin,
    required this.familyCode,
  });

  @override
  ConsumerState<ManageFamilyScreen> createState() => _ManageFamilyScreenState();
}

class _ManageFamilyScreenState extends ConsumerState<ManageFamilyScreen> {
  final _partnerController = TextEditingController();
  final List<TextEditingController> _childControllers =
      List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    _partnerController.dispose();
    for (final c in _childControllers) {
      c.dispose();
  }
    super.dispose();
  }

  Future<void> _addFamily() async {
    final partnerName = _partnerController.text.trim();
    final childNames = _childControllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    // At least one member required
    if (partnerName.isEmpty && childNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please add at least one family member.',
            style: AppTheme.caption(color: AppTheme.surface),
          ),
          backgroundColor: AppTheme.statusRejected,
        ),
      );
      return;
    }

    final uid = ref.read(authProvider).userId;
    if (uid == null) return;

    // Build member slots list for familyProvider
    final List<Map<String, dynamic>> memberSlots = [];

    if (partnerName.isNotEmpty) {
      memberSlots.add({'name': partnerName, 'isPartner': true});
    }

    for (final name in childNames) {
      memberSlots.add({'name': name, 'isPartner': false});
    }

    // Use familyProvider to create the family with all slots
    await ref.read(familyProvider.notifier).createFamily(
          creatorName: ref.read(authProvider).user?.displayName ?? 'Parent',
          parentalPin: widget.parentalPin,
          memberSlots: memberSlots,
          familyCode: widget.familyCode,
        );

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
      return;
    }

    // Navigate to parent dashboard
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
                child: Text('Manage Family', style: AppTheme.h2()),
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
                child: Text(
                  'Add your family here!',
                  style: AppTheme.sectionHeading(),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Scrollable form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXL),
                  child: Column(
                    children: [
                      // Partner field
                      TextField(
                        controller: _partnerController,
                        textAlign: TextAlign.center,
                        decoration: AppTheme.textFieldDecoration(
                            hint: 'Partner Name'),
                      ),

                      const SizedBox(height: AppTheme.itemGap),

                      // Child fields
                      ...List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppTheme.itemGap),
                          child: TextField(
                            controller: _childControllers[index],
                            textAlign: TextAlign.center,
                            decoration: AppTheme.textFieldDecoration(
                                hint: 'Child ${index + 1}'),
                          ),
                        );
                      }),

                      const SizedBox(height: AppTheme.spacingL),

                      // Add Family button
                      familyState.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.electricSky),
                              ),
                            )
                          : AppTheme.buildButton(
                              label: 'Add Family',
                              onTap: _addFamily,
                            ),

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