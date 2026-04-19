import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/family_provider.dart';
import '../../repositories/user_repository.dart';
import '../../providers/user_provider.dart';
import 'who_are_you_screen.dart';

class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinFamily() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a family code.',
              style: AppTheme.caption(color: AppTheme.surface)),
          backgroundColor: AppTheme.statusRejected,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Fetch available slots for this family code
      final slots = await ref
          .read(userRepositoryProvider)
          .fetchAvailableSlots(code);

      if (!mounted) return;

      if (slots.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No available slots found for that code.',
              style: AppTheme.caption(color: AppTheme.surface),
            ),
            backgroundColor: AppTheme.statusRejected,
          ),
        );
        return;
      }

      // Navigate to WhoAreYouScreen with familyId and available slots
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WhoAreYouScreen(
            familyId: code,
            availableSlots: slots,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(),
              style: AppTheme.caption(color: AppTheme.surface)),
          backgroundColor: AppTheme.statusRejected,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                child: Text('Join Family', style: AppTheme.h2()),
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
                  'Put your family code here\nto join your family!',
                  textAlign: TextAlign.center,
                  style: AppTheme.sectionHeading(),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Code input
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL),
                child: TextField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  decoration:
                      AppTheme.textFieldDecoration(hint: 'Fam_01234'),
                ),
              ),

              const SizedBox(height: AppTheme.itemGap),

              // Join Now button
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.electricSky),
                        ),
                      )
                    : AppTheme.buildButton(
                        label: 'Join Now',
                        onTap: _joinFamily,
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