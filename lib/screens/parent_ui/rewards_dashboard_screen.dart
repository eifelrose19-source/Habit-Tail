import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/reward_provider.dart';
import '../../providers/redemption_log_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/reward_model.dart';
import '../../models/redemption_log_model.dart';
import '../parent_ui/family_dashboard_screen.dart';
import '../parent_ui/parent_settings_screen.dart';

// ─── Local Sort State ─────────────────────────────────────────────────────────

enum RewardSortOption { title, cost, status }

final _rewardSortProvider =
    StateProvider<RewardSortOption>((ref) => RewardSortOption.title);

// ─── Screen ───────────────────────────────────────────────────────────────────

class RewardsDashboardScreen extends ConsumerWidget {
  const RewardsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userProvider).user?.name ?? 'Parent';

    return AppTheme.familyScreenWrapper(
      child: Column(
        children: [
          _RewardsAppBar(userName: userName),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  SizedBox(height: AppTheme.spacingL),
                  _CreateRewardForm(),
                  SizedBox(height: AppTheme.spacingL),
                  _SortBar(),
                  SizedBox(height: AppTheme.spacingM),
                  _RewardList(),
                  SizedBox(height: AppTheme.spacingXXL),
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

class _RewardsAppBar extends StatelessWidget {
  final String userName;
  const _RewardsAppBar({required this.userName});

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
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FamilyDashboardScreen()),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_alt_outlined,
                        color: AppTheme.surface, size: 24),
                    const SizedBox(height: 2),
                    Text('Family',
                        style: AppTheme.caption(color: AppTheme.surface)),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ParentSettingsScreen()),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.settings_outlined,
                        color: AppTheme.surface, size: 24),
                    const SizedBox(height: 2),
                    Text('Settings',
                        style: AppTheme.caption(color: AppTheme.surface)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Create Reward Form ───────────────────────────────────────────────────────

class _CreateRewardForm extends ConsumerStatefulWidget {
  const _CreateRewardForm();

  @override
  ConsumerState<_CreateRewardForm> createState() => _CreateRewardFormState();
}

class _CreateRewardFormState extends ConsumerState<_CreateRewardForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final cost = int.tryParse(_costController.text.trim()) ?? 0;
    final user = ref.read(userProvider).user;

    if (title.isEmpty || user == null) return;

    final reward = RewardModel(
      rewardId: '',
      createdBy: user.userId,
      familyId: user.familyId,
      description: description,
      isActive: true,
      isAvailable: true,
      cost: cost,
      title: title,
      timestamp: DateTime.now(),
    );

    await ref.read(rewardProvider.notifier).createReward(reward);

    _titleController.clear();
    _descriptionController.clear();
    _costController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(rewardProvider).isLoading;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(color: AppTheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create Reward', style: AppTheme.sectionHeading()),
          const SizedBox(height: AppTheme.spacingM),

          // Title
          TextField(
            controller: _titleController,
            decoration: AppTheme.textFieldDecoration(hint: 'Reward Title'),
            style: AppTheme.body(),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Description — multiline
          TextField(
            controller: _descriptionController,
            decoration: AppTheme.textFieldDecoration(hint: 'Description'),
            style: AppTheme.body(),
            maxLines: 3,
            minLines: 2,
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Cost + Add button row
          Row(
            children: [
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: AppTheme.textFieldDecoration(hint: 'Cost'),
                  style: AppTheme.body(),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: AppTheme.elevatedButtonStyle,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.midnightPlum),
                        )
                      : Text('Add Reward', style: AppTheme.buttonText()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Sort Bar ─────────────────────────────────────────────────────────────────

class _SortBar extends ConsumerWidget {
  const _SortBar();

  String _sortLabel(RewardSortOption opt) {
    switch (opt) {
      case RewardSortOption.title:
        return 'Title';
      case RewardSortOption.cost:
        return 'Cost';
      case RewardSortOption.status:
        return 'Status';
    }
  }

  void _showSortSheet(
      BuildContext context, WidgetRef ref, RewardSortOption current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXL)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text('Sort Rewards', style: AppTheme.sectionHeading()),
            const SizedBox(height: AppTheme.spacingM),
            ...RewardSortOption.values.map((opt) {
              final selected = opt == current;
              return GestureDetector(
                onTap: () {
                  ref.read(_rewardSortProvider.notifier).state = opt;
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.only(bottom: AppTheme.spacingS),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                    vertical: AppTheme.spacingM,
                  ),
                  decoration: AppTheme.cardDecoration(
                    color: selected
                        ? AppTheme.softIris
                        : AppTheme.cardLight,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_sortLabel(opt), style: AppTheme.body()),
                      if (selected)
                        const Icon(Icons.check,
                            color: AppTheme.midnightPlum, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(_rewardSortProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Sort by:', style: AppTheme.caption()),
        const SizedBox(width: AppTheme.spacingS),
        GestureDetector(
          onTap: () => _showSortSheet(context, ref, current),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingXS,
            ),
            decoration:
                AppTheme.pillDecoration(color: AppTheme.electricSky),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_sortLabel(current), style: AppTheme.caption()),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more,
                    size: 16, color: AppTheme.midnightPlum),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Reward List ──────────────────────────────────────────────────────────────

class _RewardList extends ConsumerWidget {
  const _RewardList();

  bool _isClaimed(
      RewardModel reward, List<RedemptionLogModel> logs) {
    return logs.any((log) =>
        log.rewardId == reward.rewardId &&
        (log.status == 'approved' || log.status == 'pending_approval'));
  }

  List<RewardModel> _sorted(
    List<RewardModel> rewards,
    RewardSortOption sort,
    List<RedemptionLogModel> logs,
  ) {
    final sorted = [...rewards];
    switch (sort) {
      case RewardSortOption.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        return sorted;
      case RewardSortOption.cost:
        sorted.sort((a, b) => a.cost.compareTo(b.cost));
        return sorted;
      case RewardSortOption.status:
        // Unclaimed first, claimed last
        sorted.sort((a, b) {
          final aClaimed = _isClaimed(a, logs) ? 1 : 0;
          final bClaimed = _isClaimed(b, logs) ? 1 : 0;
          return aClaimed.compareTo(bClaimed);
        });
        return sorted;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(familyRewardsProvider);
    final logsAsync = ref.watch(familyRedemptionLogsProvider);
    final sortOption = ref.watch(_rewardSortProvider);

    return rewardsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.softIris),
      ),
      error: (_, __) => Center(
        child: Text('Could not load rewards.',
            style: AppTheme.caption(color: AppTheme.statusRejected)),
      ),
      data: (rewards) {
        if (rewards.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingXL),
              child: Text(
                'No rewards added yet.',
                style: AppTheme.body(color: AppTheme.midnightPlum),
              ),
            ),
          );
        }

        final logs = logsAsync.valueOrNull ?? [];
        final sorted = _sorted(rewards, sortOption, logs);

        return Column(
          children: sorted
              .map((r) => _RewardCard(
                    reward: r,
                    isClaimed: _isClaimed(r, logs),
                  ))
              .toList(),
        );
      },
    );
  }
}

// ─── Reward Card ──────────────────────────────────────────────────────────────

class _RewardCard extends StatelessWidget {
  final RewardModel reward;
  final bool isClaimed;

  const _RewardCard({required this.reward, required this.isClaimed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.itemGap),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: AppTheme.cardDecoration(color: AppTheme.cardLight),
      child: Row(
        children: [
          // Reward details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: AppTheme.body(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    const Icon(Icons.monetization_on,
                        color: AppTheme.goldText, size: 13),
                    const SizedBox(width: 2),
                    Text(
                      'Cost: ${reward.cost}',
                      style: AppTheme.caption(),
                    ),
                  ],
                ),
                Text(
                  'Status: ${isClaimed ? 'Claimed' : 'Unclaimed'}',
                  style: AppTheme.caption(
                    color: isClaimed
                        ? AppTheme.statusCompleted
                        : AppTheme.midnightPlum,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),

          // Renew/Edit button
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: AppTheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusXL)),
              ),
              builder: (_) => _EditRewardSheet(reward: reward),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingXS,
              ),
              decoration:
                  AppTheme.pillDecoration(color: AppTheme.electricSky),
              child: Text('Renew/Edit', style: AppTheme.caption()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Edit Reward Bottom Sheet ─────────────────────────────────────────────────

class _EditRewardSheet extends ConsumerStatefulWidget {
  final RewardModel reward;
  const _EditRewardSheet({required this.reward});

  @override
  ConsumerState<_EditRewardSheet> createState() => _EditRewardSheetState();
}

class _EditRewardSheetState extends ConsumerState<_EditRewardSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _costController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reward.title);
    _descriptionController =
        TextEditingController(text: widget.reward.description);
    _costController =
        TextEditingController(text: '${widget.reward.cost}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final cost = int.tryParse(_costController.text.trim()) ?? 0;
    if (title.isEmpty) return;

    await ref.read(rewardProvider.notifier).updateReward(
      widget.reward.rewardId,
      {
        'title': title,
        'description': description,
        'cost': cost,
      },
    );

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    await ref
        .read(rewardProvider.notifier)
        .deleteReward(widget.reward.rewardId);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(rewardProvider).isLoading;

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
            Text('Edit Reward', style: AppTheme.sectionHeading()),
            const SizedBox(height: AppTheme.spacingM),

            // Title
            TextField(
              controller: _titleController,
              decoration:
                  AppTheme.textFieldDecoration(hint: 'Reward Title'),
              style: AppTheme.body(),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Description — multiline
            TextField(
              controller: _descriptionController,
              decoration:
                  AppTheme.textFieldDecoration(hint: 'Description'),
              style: AppTheme.body(),
              maxLines: 3,
              minLines: 2,
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Cost
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: AppTheme.textFieldDecoration(hint: 'Cost'),
              style: AppTheme.body(),
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Save
            ElevatedButton(
              onPressed: isLoading ? null : _save,
              style: AppTheme.elevatedButtonStyle,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.midnightPlum),
                    )
                  : Text('Save Changes', style: AppTheme.buttonText()),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Delete
            ElevatedButton(
              onPressed: isLoading ? null : _delete,
              style: AppTheme.destructiveButtonStyle,
              child: Text(
                'Delete Reward',
                style:
                    AppTheme.buttonText(color: AppTheme.statusRejected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}