import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/task_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/task_model.dart';
import '../../models/pet_model.dart';
import '../child_ui/child_shop_screen.dart';
import '../child_ui/child_settings_screen.dart';

class ChildDashboardScreen extends ConsumerWidget {
  const ChildDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final childId = user?.userId ?? '';
    final childName = user?.name ?? 'Child';
    final totalPoints = user?.totalPoints ?? 0;

    return AppTheme.childScreenWrapper(
      child: Column(
        children: [
          _ChildAppBar(
            childName: childName,
            totalPoints: totalPoints,
            onSettings: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChildSettingsScreen()),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingL),
                  _AssignedPetsSection(childId: childId),
                  const SizedBox(height: AppTheme.spacingL),
                  _ChildTaskList(childId: childId),
                  const SizedBox(height: AppTheme.spacingXL),
                  _BottomActions(),
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

class _ChildAppBar extends StatelessWidget {
  final String childName;
  final int totalPoints;
  final VoidCallback onSettings;

  const _ChildAppBar({
    required this.childName,
    required this.totalPoints,
    required this.onSettings,
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
          // App logo
          Image.asset(
            'assets/images/icons/hbtletters.png',
            height: 36,
            errorBuilder: (_, __, ___) => Text(
              'HBT',
              style: AppTheme.h2(color: AppTheme.surface),
            ),
          ),

          // Child name + gold
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
                  Text(
                    '$totalPoints Gold',
                    style: AppTheme.goldAmount(),
                  ),
                ],
              ),
            ],
          ),

          // Settings
          GestureDetector(
            onTap: onSettings,
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
    );
  }
}

// ─── Assigned Pets Section ────────────────────────────────────────────────────

class _AssignedPetsSection extends ConsumerWidget {
  final String childId;
  const _AssignedPetsSection({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(childTasksProvider(childId));
    final petsAsync = ref.watch(familyPetsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(color: AppTheme.surface),
      child: Column(
        children: [
          Text('Assigned Pets', style: AppTheme.sectionHeading()),
          const SizedBox(height: AppTheme.spacingM),
          tasksAsync.when(
            loading: () => const CircularProgressIndicator(
                color: AppTheme.softIris),
            error: (_, __) => Text('Could not load.',
                style: AppTheme.caption(
                    color: AppTheme.statusRejected)),
            data: (tasks) {
              final pets = petsAsync.asData?.value ?? [];
              // Pets that have at least one task assigned to this child
              final assignedPetIds =
                  tasks.map((t) => t.petId).toSet();
              final assignedPets = pets
                  .where((p) => assignedPetIds.contains(p.petId))
                  .toList();

              if (assignedPets.isEmpty) {
                return Text('No pets assigned yet.',
                    style: AppTheme.body());
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: assignedPets
                      .map((p) => _PetChip(pet: p))
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PetChip extends StatelessWidget {
  final PetModel pet;
  const _PetChip({required this.pet});

  String _assetForType(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
        return 'assets/images/icons/hbtdog.png';
      case 'cat':
        return 'assets/images/icons/hbtkitty.png';
      case 'hamster':
        return 'assets/images/icons/hbthamster.png';
      default:
        return 'assets/images/icons/hbtdog.png';
    }
  }

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
                _assetForType(pet.type),
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

// ─── Child Task List ──────────────────────────────────────────────────────────

class _ChildTaskList extends ConsumerWidget {
  final String childId;
  const _ChildTaskList({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(childTasksProvider(childId));
    final petsAsync = ref.watch(familyPetsProvider);

    return tasksAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.softIris),
      ),
      error: (_, __) => Center(
        child: Text('Could not load tasks.',
            style: AppTheme.caption(color: AppTheme.statusRejected)),
      ),
      data: (allTasks) {
        // Show todo and pending_approval only
        final tasks = allTasks
            .where((t) =>
                t.status == 'todo' || t.status == 'pending_approval')
            .toList();

        if (tasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingXL),
              child: Text('No tasks assigned yet.',
                  style: AppTheme.body()),
            ),
          );
        }

        final pets = petsAsync.asData?.value ?? [];

        return Column(
          children: tasks
              .map((t) => _ChildTaskCard(task: t, pets: pets))
              .toList(),
        );
      },
    );
  }
}

class _ChildTaskCard extends ConsumerWidget {
  final TaskModel task;
  final List<PetModel> pets;

  const _ChildTaskCard({required this.task, required this.pets});

  String get _petName =>
      pets.where((p) => p.petId == task.petId).firstOrNull?.name ?? '—';

  bool get _isPending => task.status == 'pending_approval';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(taskProvider).isLoading;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.itemGap),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: AppTheme.cardDecoration(
        color: _isPending
            ? AppTheme.cardLight.withAlpha(150)
            : AppTheme.cardLight,
      ),
      child: Row(
        children: [
          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTheme.body(
                    color: _isPending
                        ? AppTheme.midnightPlum.withAlpha(150)
                        : AppTheme.midnightPlum,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _petName,
                  style: AppTheme.caption(
                    color: _isPending
                        ? AppTheme.midnightPlum.withAlpha(120)
                        : AppTheme.midnightPlum,
                  ),
                ),
              ],
            ),
          ),

          // Due / frequency
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Due ${task.frequency}',
                style: AppTheme.caption(
                  color: _isPending
                      ? AppTheme.midnightPlum.withAlpha(120)
                      : AppTheme.midnightPlum,
                ),
              ),

              // Gold badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: _isPending
                        ? AppTheme.goldText.withAlpha(120)
                        : AppTheme.goldText,
                    size: 13,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${task.points}',
                    style: AppTheme.goldAmount().copyWith(
                      fontSize: 12,
                      color: _isPending
                          ? AppTheme.goldText.withAlpha(120)
                          : AppTheme.goldText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: AppTheme.spacingS),

          // Checkmark button
          GestureDetector(
            onTap: (_isPending || isLoading)
                ? null
                : () => ref
                    .read(taskProvider.notifier)
                    .submitForApproval(task.taskId),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isPending
                    ? AppTheme.electricSky.withAlpha(100)
                    : AppTheme.electricSky,
              ),
              child: Icon(
                Icons.check,
                color: _isPending
                    ? AppTheme.midnightPlum.withAlpha(100)
                    : AppTheme.midnightPlum,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Actions ───────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            // TODO: Wire streak logic when streak provider is built
            onPressed: () {},
            style: AppTheme.secondaryButtonStyle,
            child: Text('1 Day Streak! 🔥',
                style: AppTheme.buttonText()),
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ChildShopDashboardScreen()),
            ),
            style: AppTheme.elevatedButtonStyle,
            child: Text('Shop', style: AppTheme.buttonText()),
          ),
        ),
      ],
    );
  }
}