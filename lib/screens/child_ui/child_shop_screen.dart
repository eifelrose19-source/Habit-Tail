import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/reward_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/reward_model.dart';

class ChildShopDashboardScreen extends ConsumerWidget {
  const ChildShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final childName = user?.name ?? 'Child';
    final totalPoints = user?.totalPoints ?? 0;

    return AppTheme.childScreenWrapper(
      child: Column(
        children: [
          _ShopAppBar(childName: childName, totalPoints: totalPoints),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingL),
                  Center(
                    child: Text('Rewards Shop',
                        style: AppTheme.sectionHeading()),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _RewardShopList(totalPoints: totalPoints),
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

class _ShopAppBar extends StatelessWidget {
  final String childName;
  final int totalPoints;

  const _ShopAppBar({
    required this.childName,
    required this.totalPoints,
  });

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
              Text(childName,
                  style: AppTheme.body(color: AppTheme.surface)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on,
                      color: AppTheme.goldText, size: 14),
                  const SizedBox(width: 3),
                  Text('$totalPoints Gold',
                      style: AppTheme.goldAmount()),
                ],
              ),
            ],
          ),

          // Settings placeholder to balance layout
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios,
                    color: AppTheme.surface, size: 22),
                const SizedBox(height: 2),
                Text('Back',
                    style: AppTheme.caption(color: AppTheme.surface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reward Shop List ─────────────────────────────────────────────────────────

class _RewardShopList extends ConsumerWidget {
  final int totalPoints;
  const _RewardShopList({required this.totalPoints});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(familyRewardsProvider);

    return rewardsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.softIris),
      ),
      error: (_, __) => Center(
        child: Text('Could not load rewards.',
            style: AppTheme.caption(color: AppTheme.statusRejected)),
      ),
      data: (rewards) {
        // Only show active + available rewards
        final available = rewards
            .where((r) => r.isActive && r.isAvailable)
            .toList();

        if (available.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingXL),
              child: Text('No rewards available yet.',
                  style: AppTheme.body()),
            ),
          );
        }

        return Column(
          children: available
              .map((r) => _RewardShopCard(
                    reward: r,
                    totalPoints: totalPoints,
                  ))
              .toList(),
        );
      },
    );
  }
}

// ─── Reward Shop Card ─────────────────────────────────────────────────────────

class _RewardShopCard extends ConsumerStatefulWidget {
  final RewardModel reward;
  final int totalPoints;

  const _RewardShopCard({
    required this.reward,
    required this.totalPoints,
  });

  @override
  ConsumerState<_RewardShopCard> createState() => _RewardShopCardState();
}

class _RewardShopCardState extends ConsumerState<_RewardShopCard> {
  bool _purchased = false;

  Future<void> _buy() async {
    final user = ref.read(userProvider).user;
    if (user == null) return;

    final shortfall = widget.reward.cost - widget.totalPoints;
    if (shortfall > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You need $shortfall more Gold to buy this reward.',
            style: AppTheme.caption(color: AppTheme.surface),
          ),
          backgroundColor: AppTheme.statusRejected,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    await ref.read(rewardProvider.notifier).redeemReward(
          childId: user.userId,
          parentId: user.parentId ?? '',
          rewardId: widget.reward.rewardId,
        );

    if (mounted) {
      setState(() => _purchased = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 ${widget.reward.title} redeemed! Waiting for parent approval.',
            style: AppTheme.caption(color: AppTheme.surface),
          ),
          backgroundColor: AppTheme.statusCompleted,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(rewardProvider).isLoading;
    final canAfford = widget.totalPoints >= widget.reward.cost;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: AppTheme.cardDecoration(color: AppTheme.surface),
      child: Row(
        children: [
          // Generic reward icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.electricSky,
              borderRadius:
                  BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: AppTheme.midnightPlum,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),

          // Reward details + buy button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.reward.title, style: AppTheme.body()),
                if (widget.reward.description.isNotEmpty)
                  Text(
                    widget.reward.description,
                    style: AppTheme.caption(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: AppTheme.spacingS),

                // Buy button
                GestureDetector(
                  onTap: (_purchased || isLoading) ? null : _buy,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: _purchased
                          ? AppTheme.statusCompleted
                          : canAfford
                              ? AppTheme.electricSky
                              : AppTheme.cardLight,
                      borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on,
                            color: AppTheme.goldText, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _purchased
                              ? 'Purchased!'
                              : 'Buy for ${widget.reward.cost} Gold',
                          style: AppTheme.caption(
                            color: _purchased
                                ? AppTheme.surface
                                : AppTheme.midnightPlum,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}