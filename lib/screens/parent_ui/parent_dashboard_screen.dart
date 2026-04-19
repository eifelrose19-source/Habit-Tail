import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/pet_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../models/pet_model.dart';
import '../parent_ui/family_dashboard_screen.dart';
import '../parent_ui/parent_settings_screen.dart';
import '../parent_ui/pets_dashboard_screen.dart';
import '../parent_ui/tasks_dashboard_screen.dart';
import '../parent_ui/rewards_dashboard_screen.dart';

/// Maps PetModel.type (lowercase) → asset path under assets/images/icons/
String _petAssetForType(String type) {
  switch (type.toLowerCase()) {
    case 'dog':
      return 'assets/images/icons/hbtdog.png';
    case 'cat':
      return 'assets/images/icons/hbtkitty.png';
    case 'hamster':
      return 'assets/images/icons/hbthamster.png';
    default:
      // Falls back to dog icon; update when more types are added
      return 'assets/images/icons/hbtdog.png';
  }
}

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final userName = userState.user?.name ?? 'Parent';

    return AppTheme.parentScreenWrapper(
      child: Column(
        children: [
          _ParentAppBar(userName: userName),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.spacingL),
                  _PetsDashboardSection(),
                  const SizedBox(height: AppTheme.spacingXL),
                  _TasksAwaitingReviewSection(),
                  const SizedBox(height: AppTheme.spacingXL),
                  _ManagementSection(),
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

// ─── App Bar ────────────────────────────────────────────────────────────────

class _ParentAppBar extends StatelessWidget {
  final String userName;
  const _ParentAppBar({required this.userName});

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
          Text(
            'Welcome,\n$userName!',
            style: AppTheme.h2(color: AppTheme.surface),
          ),
          Row(
            children: [
              _AppBarIconButton(
                icon: Icons.people_alt_outlined,
                label: 'Family',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FamilyDashboardScreen(),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              _AppBarIconButton(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ParentSettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AppBarIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.surface, size: 24),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.caption(color: AppTheme.surface)),
        ],
      ),
    );
  }
}

// ─── Pets Dashboard Section ──────────────────────────────────────────────────

class _PetsDashboardSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(familyPetsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(color: AppTheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Pets Dashboard', style: AppTheme.sectionHeading()),
          const SizedBox(height: AppTheme.spacingM),
          petsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.softIris),
            ),
            error: (_, __) => Center(
              child: Text('Could not load pets.',
                  style: AppTheme.caption(color: AppTheme.statusRejected)),
            ),
            data: (pets) => _PetsRow(pets: pets),
          ),
        ],
      ),
    );
  }
}

class _PetsRow extends StatelessWidget {
  final List<PetModel> pets;
  const _PetsRow({required this.pets});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...pets.map((pet) => _PetAvatar(pet: pet)),
        const SizedBox(width: AppTheme.spacingS),
        _AddPetButton(),
      ],
    );
  }
}

class _PetAvatar extends StatelessWidget {
  final PetModel pet;
  const _PetAvatar({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            child: ClipOval(
              child: Image.asset(
                _petAssetForType(pet.type),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.pets,
                  color: AppTheme.midnightPlum,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(pet.name, style: AppTheme.petName()),
        ],
      ),
    );
  }
}

class _AddPetButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PetsDashboardScreen()),
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.electricSky,
          border: Border.all(color: AppTheme.softIris, width: 1.5),
        ),
        child: const Icon(Icons.add, color: AppTheme.midnightPlum, size: 22),
      ),
    );
  }
}

// ─── Tasks Awaiting Review Section ───────────────────────────────────────────

class _TasksAwaitingReviewSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingTasksAsync = ref.watch(pendingApprovalTasksProvider);
    final familyMembersAsync = ref.watch(familyMembersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text('Tasks Awaiting Review', style: AppTheme.sectionHeading()),
        ),
        const SizedBox(height: AppTheme.spacingM),
        pendingTasksAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.softIris),
          ),
          error: (_, __) => Center(
            child: Text('Could not load tasks.',
                style: AppTheme.caption(color: AppTheme.statusRejected)),
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXL),
                  child: Text(
                    'No tasks awaiting review',
                    style: AppTheme.body(color: AppTheme.midnightPlum),
                  ),
                ),
              );
            }

            final members = familyMembersAsync.valueOrNull ?? [];

            return Column(
              children: tasks
                  .map((task) => _TaskReviewCard(task: task, allMembers: members))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _TaskReviewCard extends ConsumerWidget {
  final TaskModel task;
  final List<UserModel> allMembers;

  const _TaskReviewCard({required this.task, required this.allMembers});

  String _resolveAssignedNames() {
    if (allMembers.isEmpty) return task.assignedTo.join(', ');

    final names = task.assignedTo.map((id) {
      final match = allMembers.where((m) => m.userId == id).firstOrNull;
      return match?.name ?? id;
    }).toList();

    return names.join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskNotifier = ref.read(taskProvider.notifier);
    final isLoading = ref.watch(taskProvider).isLoading;
    final assignedNames = _resolveAssignedNames();

    // Use first assigned child ID for point awarding
    final firstChildId =
        task.assignedTo.isNotEmpty ? task.assignedTo.first : '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.itemGap),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: AppTheme.cardDecoration(color: AppTheme.cardLight),
      child: Row(
        children: [
          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task: ${task.title}',
                  style: AppTheme.body(color: AppTheme.midnightPlum),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Submitted by: $assignedNames',
                  style: AppTheme.caption(color: AppTheme.midnightPlum),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),

          // Coin badge
          _CoinBadge(points: task.points),
          const SizedBox(width: AppTheme.spacingS),

          // Reject button
          _ActionButton(
            icon: Icons.close,
            color: AppTheme.blushPink,
            isLoading: isLoading,
            onTap: () => taskNotifier.rejectTask(task.taskId),
          ),
          const SizedBox(width: AppTheme.spacingXS),

          // Approve button
          _ActionButton(
            icon: Icons.check,
            color: AppTheme.electricSky,
            isLoading: isLoading,
            onTap: () => taskNotifier.approveTask(
              task.taskId,
              firstChildId,
              task.points,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinBadge extends StatelessWidget {
  final int points;
  const _CoinBadge({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: AppTheme.pillDecoration(color: AppTheme.softIris),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: AppTheme.goldText, size: 16),
          const SizedBox(width: 3),
          Text(
            '$points',
            style: AppTheme.goldAmount().copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.midnightPlum, size: 20),
      ),
    );
  }
}

// ─── Management Section ───────────────────────────────────────────────────────

class _ManagementSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.softIris,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      ),
      child: Column(
        children: [
          Text('Management', style: AppTheme.sectionHeading()),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TasksDashboardScreen(),
                    ),
                  ),
                  style: AppTheme.elevatedButtonStyle,
                  child: Text('Manage Tasks', style: AppTheme.buttonText()),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RewardsDashboardScreen(),
                    ),
                  ),
                  style: AppTheme.elevatedButtonStyle,
                  child: Text('Manage Rewards', style: AppTheme.buttonText()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}