import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/pet_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/family_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/pet_model.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../parent_ui/family_dashboard_screen.dart';
import '../parent_ui/parent_settings_screen.dart';
import '../parent_ui/tasks_dashboard_screen.dart';

// ─── Selected Pet Provider ────────────────────────────────────────────────────

final _selectedPetProvider = NotifierProvider<PetModel?>((ref) => null);

// ─── Pet Type Asset Helper ────────────────────────────────────────────────────

String _petAssetForType(String type) {
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

// ─── Screen ───────────────────────────────────────────────────────────────────

class PetsDashboardScreen extends ConsumerWidget {
  const PetsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userProvider).user?.name ?? 'Parent';
    final petsAsync = ref.watch(familyPetsProvider);

    // Auto-select first pet when pets load and none selected
    ref.listen(familyPetsProvider, (_, next) {
      next.whenData((pets) {
        if (pets.isNotEmpty &&
            ref.read(_selectedPetProvider).state == null) {
          ref.read(_selectedPetProvider.notifier).state = pets.first;
        }
      });
    });

    return AppTheme.parentScreenWrapper(
      child: Column(
        children: [
          _PetsAppBar(userName: userName),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingL),

                  // ── Pets row ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    decoration:
                        AppTheme.cardDecoration(color: AppTheme.surface),
                    child: Column(
                      children: [
                        Text('Pets Dashboard',
                            style: AppTheme.sectionHeading()),
                        const SizedBox(height: AppTheme.spacingM),
                        petsAsync.when(
                          loading: () => const CircularProgressIndicator(
                              color: AppTheme.softIris),
                          error: (_, __) => Text('Could not load pets.',
                              style: AppTheme.caption(
                                  color: AppTheme.statusRejected)),
                          data: (pets) => _PetsRow(pets: pets),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingL),

                  // ── Selected pet sections ──
                  const _SelectedPetTaskSection(),
                  const SizedBox(height: AppTheme.spacingL),
                  const _SelectedPetInfoSection(),
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

class _PetsAppBar extends StatelessWidget {
  final String userName;
  const _PetsAppBar({required this.userName});

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

// ─── Pets Row ─────────────────────────────────────────────────────────────────

class _PetsRow extends ConsumerWidget {
  final List<PetModel> pets;
  const _PetsRow({required this.pets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPet = ref.watch(_selectedPetProvider).state;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: pets.map((pet) {
          final isSelected = selectedPet?.petId == pet.petId;
          return GestureDetector(
            onTap: () =>
                ref.read(_selectedPetProvider.notifier).state = pet,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS),
              child: Column(
                children: [
                  Container(
                    width: AppTheme.petAvatarSize,
                    height: AppTheme.petAvatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.electricSky,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.midnightPlum
                            : AppTheme.softIris,
                        width: isSelected ? 3 : 2,
                      ),
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
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Selected Pet Task Section ────────────────────────────────────────────────

class _SelectedPetTaskSection extends ConsumerWidget {
  const _SelectedPetTaskSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPet = ref.watch(_selectedPetProvider).state;
    final tasksAsync = ref.watch(familyTasksProvider);
    final membersAsync = ref.watch(familyMembersProvider);

    if (selectedPet == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "${selectedPet.name}'s Dashboard",
            style: AppTheme.sectionHeading(),
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        tasksAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.softIris),
          ),
          error: (_, __) => Center(
            child: Text('Could not load tasks.',
                style: AppTheme.caption(
                    color: AppTheme.statusRejected)),
          ),
          data: (allTasks) {
            final petTasks = allTasks
                .where((t) => t.petId == selectedPet.petId)
                .toList();

            if (petTasks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingL),
                  child: Text(
                    'No tasks for ${selectedPet.name} yet.',
                    style: AppTheme.body(),
                  ),
                ),
              );
            }

            final members = membersAsync.asData?.value ?? [];

            return Column(
              children: petTasks
                  .map((t) => _PetTaskCard(task: t, members: members))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

// ─── Pet Task Card ────────────────────────────────────────────────────────────

class _PetTaskCard extends StatelessWidget {
  final TaskModel task;
  final List<UserModel> members;

  const _PetTaskCard({required this.task, required this.members});

  String get _assignedNames {
    if (members.isEmpty) return task.assignedTo.join(', ');
    return task.assignedTo.map((id) {
      return members.where((m) => m.userId == id).firstOrNull?.name ?? id;
    }).join(', ');
  }

  String get _statusLabel {
    switch (task.status) {
      case 'completed':
        return 'Completed';
      case 'pending_approval':
        return 'Pending';
      case 'todo':
        return 'To Do';
      default:
        return task.status;
    }
  }

  Color get _statusColor {
    switch (task.status) {
      case 'completed':
        return AppTheme.statusCompleted;
      case 'pending_approval':
        return AppTheme.statusPending;
      default:
        return AppTheme.midnightPlum;
    }
  }

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
                  'Assigned to: $_assignedNames',
                  style: AppTheme.caption(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Status: $_statusLabel',
                  style: AppTheme.caption(color: _statusColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),

          // Edit Task — navigates to TasksDashboardScreen, scrolled to task
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TasksDashboardScreen(
                  highlightTaskId: task.taskId,
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingXS,
              ),
              decoration:
                  AppTheme.pillDecoration(color: AppTheme.electricSky),
              child: Text('Edit Task', style: AppTheme.caption()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Selected Pet Info Section ────────────────────────────────────────────────

class _SelectedPetInfoSection extends ConsumerWidget {
  const _SelectedPetInfoSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPet = ref.watch(_selectedPetProvider).state;
    if (selectedPet == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(color: AppTheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with pet name + Edit Pet button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${selectedPet.name}'s Info",
                  style: AppTheme.sectionHeading()),
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppTheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusXL)),
                  ),
                  builder: (_) => _EditPetSheet(pet: selectedPet),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: AppTheme.pillDecoration(
                      color: AppTheme.electricSky),
                  child: Text('Edit Pet', style: AppTheme.caption()),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Two-column info layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left — basic pet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'Pet Name', value: selectedPet.name),
                    _InfoRow(label: 'Species', value: selectedPet.type),
                    _InfoRow(label: 'Breed', value: selectedPet.breed),
                    _InfoRow(label: 'Gender', value: selectedPet.gender),
                    _InfoRow(
                        label: 'Age',
                        value: '${selectedPet.age}'),
                    _InfoRow(
                        label: 'Pet License',
                        value: selectedPet.petLicense),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingL),

              // Right — vet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vet Info', style: AppTheme.body()),
                    const SizedBox(height: AppTheme.spacingXS),
                    _InfoRow(
                        label: 'Dr. Name',
                        value: selectedPet.veterinarian),
                    _InfoRow(
                        label: 'Vet Address',
                        value: selectedPet.vetOffice),
                    _InfoRow(
                        label: 'Vet Phone',
                        value: selectedPet.vetNumber),
                    _InfoRow(
                        label: 'Pet Meds',
                        value: selectedPet.petMeds),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingXS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTheme.caption(color: AppTheme.midnightPlum)
                  .copyWith(fontWeight: FontWeight.w700)),
          Text(
            value.isEmpty ? '—' : value,
            style: AppTheme.caption(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Edit Pet Bottom Sheet ────────────────────────────────────────────────────

class _EditPetSheet extends ConsumerStatefulWidget {
  final PetModel pet;
  const _EditPetSheet({required this.pet});

  @override
  ConsumerState<_EditPetSheet> createState() => _EditPetSheetState();
}

class _EditPetSheetState extends ConsumerState<_EditPetSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _genderController;
  late final TextEditingController _ageController;
  late final TextEditingController _licenseController;
  late final TextEditingController _vetNameController;
  late final TextEditingController _vetAddressController;
  late final TextEditingController _vetPhoneController;
  late final TextEditingController _petMedsController;
  late String _selectedType;

  static const _types = ['Dog', 'Cat', 'Hamster'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _breedController = TextEditingController(text: widget.pet.breed);
    _genderController = TextEditingController(text: widget.pet.gender);
    _ageController =
        TextEditingController(text: '${widget.pet.age}');
    _licenseController =
        TextEditingController(text: widget.pet.petLicense);
    _vetNameController =
        TextEditingController(text: widget.pet.veterinarian);
    _vetAddressController =
        TextEditingController(text: widget.pet.vetOffice);
    _vetPhoneController =
        TextEditingController(text: widget.pet.vetNumber);
    _petMedsController =
        TextEditingController(text: widget.pet.petMeds);
    _selectedType = _types.firstWhere(
      (t) => t.toLowerCase() == widget.pet.type.toLowerCase(),
      orElse: () => 'Dog',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    _licenseController.dispose();
    _vetNameController.dispose();
    _vetAddressController.dispose();
    _vetPhoneController.dispose();
    _petMedsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(petProvider.notifier).updatePet(widget.pet.petId, {
      'name': _nameController.text.trim(),
      'type': _selectedType.toLowerCase(),
      'breed': _breedController.text.trim(),
      'gender': _genderController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'pet_license': _licenseController.text.trim(),
      'veterinarian': _vetNameController.text.trim(),
      'vet_office': _vetAddressController.text.trim(),
      'vet_number': _vetPhoneController.text.trim(),
      'pet_meds': _petMedsController.text.trim(),
    });

    if (mounted) {
      // Refresh selected pet state with updated values
      ref.read(_selectedPetProvider.notifier).state = null;
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    await ref.read(petProvider.notifier).deletePet(widget.pet.petId);
    if (mounted) {
      ref.read(_selectedPetProvider.notifier).state = null;
      Navigator.pop(context);
    }
  }

  Widget _buildField(String hint, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: keyboard == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: AppTheme.textFieldDecoration(hint: hint),
        style: AppTheme.body(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(petProvider).isLoading;

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
            Text('Edit Pet', style: AppTheme.sectionHeading()),
            const SizedBox(height: AppTheme.spacingM),

            // Type selector
            Wrap(
              spacing: AppTheme.spacingXS,
              children: _types.map((t) {
                final selected = _selectedType == t;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = t),
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
                    child: Text(t, style: AppTheme.caption()),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spacingM),

            _buildField('Pet Name', _nameController),
            _buildField('Breed', _breedController),
            _buildField('Gender', _genderController),
            _buildField('Age', _ageController,
                keyboard: TextInputType.number),
            _buildField('Pet License', _licenseController),

            // Vet info section
            Text('Vet Info', style: AppTheme.body()),
            const SizedBox(height: AppTheme.spacingS),
            _buildField('Dr. Name', _vetNameController),
            _buildField('Vet Address', _vetAddressController),
            _buildField('Vet Phone', _vetPhoneController,
                keyboard: TextInputType.phone),
            _buildField('Pet Meds', _petMedsController),

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
                'Delete Pet',
                style: AppTheme.buttonText(
                    color: AppTheme.statusRejected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}