import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/family_provider.dart';
import 'manage_family_screen.dart';

class CreateFamilyCodeScreen extends ConsumerStatefulWidget {
  const CreateFamilyCodeScreen({super.key});

  @override
  ConsumerState<CreateFamilyCodeScreen> createState() =>
      _CreateFamilyCodeScreenState();
}

class _CreateFamilyCodeScreenState
    extends ConsumerState<CreateFamilyCodeScreen> {
  // Generate the family code once when screen is created
  late final String _familyCode;

  @override
  void initState() {
    super.initState();
    _familyCode =
        ref.read(familyProvider.notifier).generateFamilyId();
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _familyCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Family code copied!',
            style: AppTheme.caption(color: AppTheme.surface)),
        backgroundColor: AppTheme.statusCompleted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                child: Text('Create Family Code', style: AppTheme.h2()),
              ),

              const Spacer(flex: 2),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/icons/hbtletters.png',
                  width: screenWidth * 0.65,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(flex: 2),

              // Instruction text
              Center(
                child: Text(
                  'Below is your family code!\nShare with your family members\nto create your family account.',
                  textAlign: TextAlign.center,
                  style: AppTheme.sectionHeading(),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Family code display
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL),
                child: Container(
                  height: AppTheme.tappableHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _familyCode,
                    style: AppTheme.sectionHeading(),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.itemGap),

              // Copy Code button
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL),
                child: AppTheme.buildButton(
                  label: 'Copy Code',
                  onTap: _copyCode,
                ),
              ),

              const SizedBox(height: AppTheme.itemGap),

              // Create Family Members button
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL),
                child: AppTheme.buildButton(
                  label: 'Create Family Members',
                  style: AppTheme.outlineButtonStyle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ManageFamilyScreen(
                        familyCode: _familyCode,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

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