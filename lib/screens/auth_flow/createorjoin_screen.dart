import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'create_pin_screen.dart';
import 'join_family_screen.dart';

class CreateOrJoinScreen extends ConsumerWidget {
  const CreateOrJoinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final authState = ref.watch(authProvider);

    // If somehow unauthenticated, nothing to show
    if (!authState.isAuthenticated) return const SizedBox.shrink();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spacingXXL),

                // Title
                Text('Create or Join...', style: AppTheme.h2()),

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

                // Create Family button
                AppTheme.buildButton(
                  label: 'Create Family',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreatePinScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.itemGap),

                // Join Family button
                AppTheme.buildButton(
                  label: 'Join Family',
                  style: AppTheme.outlineButtonStyle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const JoinFamilyScreen(),
                    ),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}