import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/task_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/family_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/task_model.dart';
import '../../models/pet_model.dart';
import '../../models/user_model.dart';
import '../parent_ui/family_dashboard_screen.dart';
import '../parent_ui/parent_settings_screen.dart';

// ─── Sort Enum ────────────────────────────────────────────────────────────────

enum TaskSortOption { timeCreated, pet, child }

// ─── Local Sort State Provider ────────────────────────────────────────────────

class _TaskSortNotifier extends Notifier<TaskSortOption> {
  @override
  TaskSortOption build() => TaskSortOption.timeCreated;
  void set(TaskSortOption opt) => state = opt;
}

final _taskSortProvider =
    NotifierProvider<_TaskSortNotifier, TaskSortOption>(_TaskSortNotifier.new);

// ─── Highlight Task Provider ──────────────────────────────────────────────────

class _HighlightTaskNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? id) => state = id;
}

final _highlightTaskIdProvider =
    NotifierProvider<_HighlightTaskNotifier, String?>(_HighlightTaskNotifier.new);

// ─── Screen ───────────────────────────────────────────────────────────────────

class TasksDashboardScreen extends ConsumerStatefulWidget {
  /// When provided, the list scrolls to and highlights this task on load.
  final String? highlightTaskId;
  const TasksDashboardScreen({super.key, this.highlightTaskId});

  @override
  ConsumerState<TasksDashboardScreen> createState() =>
      _TasksDashboardScreenState();
}

class _TasksDashboardScreenState extends ConsumerState<TasksDashboardScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.highlightTaskId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(_highlightTaskIdProvider.notifier).set(widget.highlightTaskId);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userProvider).user?.name ?? 'Parent';

    return AppTheme.familyScreenWrapper(
      child: Column(
        children: [
          _TasksAppBar(userName: userName),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingL),
                  const _CreateTaskForm(),
                  const SizedBox(height: AppTheme.spacingL),
                  const _SortBar(),
                  const SizedBox(height: AppTheme.spacingM),
                  _TaskList(scrollController: _scrollController),
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

class _TasksAppBar extends StatelessWidget {
  final String userName;
  const _TasksAppBar({required this.userName});

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

// ─── Create Task Form ─────────────────────────────────────────────────────────

class _CreateTaskForm extends ConsumerStatefulWidget {
  const _CreateTaskForm();

  @override
  ConsumerState<_CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends ConsumerState<_CreateTaskForm> {
  final _titleController = TextEditingController();
  final _pointsController = TextEditingController();

  PetModel? _selectedPet;
  UserModel? _selectedChild;
  String _selectedFrequency = 'Daily';

  static const _frequencies = ['Daily', 'Weekly', 'Monthly'];

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final points = int.tryParse(_pointsController.text.trim()) ?? 0;
    final familyId = ref.read(userProvider).user?.familyId ?? '';
    final createdBy = ref.read(userProvider).user?.userId ?? '';

    if (title.isEmpty || _selectedPet == null || _selectedChild == null) return;

    final task = TaskModel(
      taskId: '',
      assignedTo: [_selectedChild!.userId],
      createdBy: createdBy,
      familyId: familyId,
      frequency: _selectedFrequency,
      points: points,
      title: title,
      status: 'todo',
      petId: _selectedPet!.petId,
    );

    await ref.read(taskProvider.notifier).createTask(task);

    _titleController.clear();
    _pointsController.clear();
    setState(() {
      _selectedPet = null;
      _selectedChild = null;
      _selectedFrequency = 'Daily';
    });
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(familyPetsProvider);
    final membersAsync = ref.watch(familyMembersProvider);
    final isLoading = ref.watch(taskProvider).isLoading;

    final pets = petsAsync.asData?.value ?? [];
    final children = (membersAsync.asData?.value ?? [])
        .where((m) => !m.isParent)
        .toList();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(color: AppTheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create Task', style: AppTheme.sectionHeading()),
          const SizedBox(height: AppTheme.spacingM),

          // Task Title
          TextField(
            controller: _titleController,
            decoration: AppTheme.textFieldDecoration(hint: 'Task Title'),
            style: AppTheme.body(),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Assigned Pet dropdown
          _StyledDropdown<PetModel>(
            hint: 'Assigned Pet',
            value: _selectedPet,
            items: pets,
            labelBuilder: (p) => p.name,
            onChanged: (p) => setState(() => _selectedPet = p),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Assigned To dropdown — children only
          _StyledDropdown<UserModel>(
            hint: 'Assigned To',
            value: _selectedChild,
            items: children,
            labelBuilder: (u) => u.name,
            onChanged: (u) => setState(() => _selectedChild = u),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Reward + Frequency row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Points input
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: AppTheme.textFieldDecoration(hint: '100'),
                  style: AppTheme.body(),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),

              // Frequency toggles
              Expanded(
                child: Wrap(
                  spacing: AppTheme.spacingXS,
                  children: _frequencies.map((f) {
                    final selected = _selectedFrequency == f;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFrequency = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.softIris
                              : AppTheme.electricSky,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(f, style: AppTheme.caption()),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Add Task button
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: AppTheme.elevatedButtonStyle,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.midnightPlum),
                  )
                : Text('Add Task', style: AppTheme.buttonText()),
          ),
        ],
      ),
    );
  }
}

// ─── Styled Dropdown ──────────────────────────────────────────────────────────

class _StyledDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.electricSky, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: AppTheme.inputHint()),
          isExpanded: true,
          style: AppTheme.body(),
          dropdownColor: AppTheme.surface,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(labelBuilder(item), style: AppTheme.body()),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Sort Bar ─────────────────────────────────────────────────────────────────

class _SortBar extends ConsumerWidget {
  const _SortBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(_taskSortProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Sort by:', style: AppTheme.caption()),
        const SizedBox(width: AppTheme.spacingS),
        GestureDetector(
          onTap: () => _showSortOptions(context, ref, current),
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

  String _sortLabel(TaskSortOption opt) {
    switch (opt) {
      case TaskSortOption.timeCreated:
        return 'Time Created';
      case TaskSortOption.pet:
        return 'Pet';
      case TaskSortOption.child:
        return 'Child';
    }
  }

  void _showSortOptions(
      BuildContext context, WidgetRef ref, TaskSortOption current) {
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
            Text('Sort Tasks', style: AppTheme.sectionHeading()),
            const SizedBox(height: AppTheme.spacingM),
            ...TaskSortOption.values.map((opt) {
              final selected = opt == current;
              return GestureDetector(
                onTap: () {
                  ref.read(_taskSortProvider.notifier).set(opt);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                    vertical: AppTheme.spacingM,
                  ),
                  decoration: AppTheme.cardDecoration(
                    color: selected ? AppTheme.softIris : AppTheme.cardLight,
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
}

// ─── Task List ────────────────────────────────────────────────────────────────

class _TaskList extends ConsumerWidget {
  final ScrollController scrollController;
  const _TaskList({required this.scrollController});

  List<TaskModel> _sorted(
    List<TaskModel> tasks,
    TaskSortOption sort,
    List<PetModel> pets,
    List<UserModel> members,
  ) {
    final sorted = [...tasks];
    switch (sort) {
      case TaskSortOption.timeCreated:
        // Tasks from Firestore are already ordered by creation;
        // reverse so newest is first
        return sorted.reversed.toList();
      case TaskSortOption.pet:
        sorted.sort((a, b) {
          final petA =
              pets.where((p) => p.petId == a.petId).firstOrNull?.name ?? '';
          final petB =
              pets.where((p) => p.petId == b.petId).firstOrNull?.name ?? '';
          return petA.compareTo(petB);
        });
        return sorted;
      case TaskSortOption.child:
        sorted.sort((a, b) {
          final nameA = a.assignedTo.isNotEmpty
              ? members
                      .where((m) => m.userId == a.assignedTo.first)
                      .firstOrNull
                      ?.name ??
                  ''
              : '';
          final nameB = b.assignedTo.isNotEmpty
              ? members
                      .where((m) => m.userId == b.assignedTo.first)
                      .firstOrNull
                      ?.name ??
                  ''
              : '';
          return nameA.compareTo(nameB);
        });
        return sorted;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(familyTasksProvider);
    final petsAsync = ref.watch(familyPetsProvider);
    final membersAsync = ref.watch(familyMembersProvider);
    final sortOption = ref.watch(_taskSortProvider);

    return tasksAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.softIris),
      ),
      error: (_, __) => Center(
        child: Text('Could not load tasks.',
            style: AppTheme.caption(color: AppTheme.statusRejected)),
      ),
      data: (allTasks) {
        // Filter: only todo and pending_approval
        final tasks = allTasks
            .where((t) =>
                t.status == 'todo' || t.status == 'pending_approval')
            .toList();

        if (tasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXL),
              child: Text(
                'No task history yet.',
                style: AppTheme.body(color: AppTheme.midnightPlum),
              ),
            ),
          );
        }

        final pets = petsAsync.asData?.value ?? [];
        final members = membersAsync.asData?.value ?? [];
        final sorted = _sorted(tasks, sortOption, pets, members);
        final highlightId = ref.watch(_highlightTaskIdProvider);

        // Scroll to highlighted task after layout
        if (highlightId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final index =
                sorted.indexWhere((t) => t.taskId == highlightId);
            if (index != -1 && scrollController.hasClients) {
              // Approximate card height + spacing
              const cardHeight = 90.0;
              const formOffset = 320.0; // create form + sort bar
              scrollController.animateTo(
                formOffset + (index * (cardHeight + AppTheme.itemGap)),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
            }
          });
        }

        return Column(
          children: sorted
              .map((t) => _TaskCard(
                    task: t,
                    pets: pets,
                    members: members,
                    isHighlighted: t.taskId == highlightId,
                  ))
              .toList(),
        );
      },
    );
  }
}

// ─── Task Card ────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final List<PetModel> pets;
  final List<UserModel> members;
  final bool isHighlighted;

  const _TaskCard({
    required this.task,
    required this.pets,
    required this.members,
    this.isHighlighted = false,
  });

  String get _petName =>
      pets.where((p) => p.petId == task.petId).firstOrNull?.name ?? '—';

  String get _assignedNames {
    if (members.isEmpty) return task.assignedTo.join(', ');
    return task.assignedTo.map((id) {
      return members.where((m) => m.userId == id).firstOrNull?.name ?? id;
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.itemGap),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: isHighlighted
          ? AppTheme.cardDecoration(color: AppTheme.cardLight).copyWith(
              border: Border.all(color: AppTheme.softIris, width: 2),
            )
          : AppTheme.cardDecoration(color: AppTheme.cardLight),
      child: Row(
        children: [
          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task: ${task.title}',
                  style: AppTheme.body(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Pet: $_petName',
                  style: AppTheme.caption(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Assigned to: $_assignedNames',
                  style: AppTheme.caption(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Due: ${task.frequency}',
                  style: AppTheme.caption(),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),

          // Gold badge
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on,
                      color: AppTheme.goldText, size: 14),
                  const SizedBox(width: 2),
                  Text('${task.points}',
                      style: AppTheme.goldAmount().copyWith(fontSize: 13)),
                ],
              ),
              const SizedBox(height: AppTheme.spacingXS),

              // Update/Edit button
              GestureDetector(
                onTap: () => _showEditSheet(context, task, pets, members),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: AppTheme.pillDecoration(
                      color: AppTheme.electricSky),
                  child: Text('Update/Edit',
                      style: AppTheme.caption()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditSheet(
    BuildContext context,
    TaskModel task,
    List<PetModel> pets,
    List<UserModel> members,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXL)),
      ),
      builder: (_) => _EditTaskSheet(
        task: task,
        pets: pets,
        members: members,
      ),
    );
  }
}

// ─── Edit Task Bottom Sheet ───────────────────────────────────────────────────

class _EditTaskSheet extends ConsumerStatefulWidget {
  final TaskModel task;
  final List<PetModel> pets;
  final List<UserModel> members;

  const _EditTaskSheet({
    required this.task,
    required this.pets,
    required this.members,
  });

  @override
  ConsumerState<_EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends ConsumerState<_EditTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _pointsController;
  late PetModel? _selectedPet;
  late UserModel? _selectedChild;
  late String _selectedFrequency;

  static const _frequencies = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.task.title);
    _pointsController =
        TextEditingController(text: '${widget.task.points}');
    _selectedPet = widget.pets
        .where((p) => p.petId == widget.task.petId)
        .firstOrNull;
    _selectedChild = widget.task.assignedTo.isNotEmpty
        ? widget.members
            .where((m) => m.userId == widget.task.assignedTo.first)
            .firstOrNull
        : null;
    _selectedFrequency = widget.task.frequency.isNotEmpty
        ? widget.task.frequency
        : 'Daily';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final points = int.tryParse(_pointsController.text.trim()) ?? 0;
    if (title.isEmpty) return;

    await ref.read(taskProvider.notifier).updateTask(widget.task.taskId, {
      'title': title,
      'pet_id': _selectedPet?.petId ?? widget.task.petId,
      'assigned_to': _selectedChild != null
          ? [_selectedChild!.userId]
          : widget.task.assignedTo,
      'frequency': _selectedFrequency,
      'points': points,
    });

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    await ref.read(taskProvider.notifier).deleteTask(widget.task.taskId);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(taskProvider).isLoading;
    final children =
        widget.members.where((m) => !m.isParent).toList();

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
            Text('Edit Task', style: AppTheme.sectionHeading()),
            const SizedBox(height: AppTheme.spacingM),

            // Title
            TextField(
              controller: _titleController,
              decoration: AppTheme.textFieldDecoration(hint: 'Task Title'),
              style: AppTheme.body(),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Pet dropdown
            _StyledDropdown<PetModel>(
              hint: 'Assigned Pet',
              value: _selectedPet,
              items: widget.pets,
              labelBuilder: (p) => p.name,
              onChanged: (p) => setState(() => _selectedPet = p),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Child dropdown
            _StyledDropdown<UserModel>(
              hint: 'Assigned To',
              value: _selectedChild,
              items: children,
              labelBuilder: (u) => u.name,
              onChanged: (u) => setState(() => _selectedChild = u),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Points + Frequency
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _pointsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration:
                        AppTheme.textFieldDecoration(hint: 'Points'),
                    style: AppTheme.body(),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Wrap(
                    spacing: AppTheme.spacingXS,
                    children: _frequencies.map((f) {
                      final selected = _selectedFrequency == f;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedFrequency = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.softIris
                                : AppTheme.electricSky,
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull),
                          ),
                          child:
                              Text(f, style: AppTheme.caption()),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Save button
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

            // Delete button
            ElevatedButton(
              onPressed: isLoading ? null : _delete,
              style: AppTheme.destructiveButtonStyle,
              child: Text('Delete Task',
                  style: AppTheme.buttonText(
                      color: AppTheme.statusRejected)),
            ),
          ],
        ),
      ),
    );
  }
}