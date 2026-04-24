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

class _SelectedPetNotifier extends Notifier<PetModel?> {
  @override
  PetModel? build() => null;
  void set(PetModel? pet) => state = pet;
}

final _selectedPetProvider =
    NotifierProvider<_SelectedPetNotifier, PetModel?>(_SelectedPetNotifier.new);

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

void _showAddPetSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL)),
    ),
    builder: (_) => const _AddPetSheet(),
  );
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
        if (pets.isNotEmpty && ref.read(_selectedPetProvider) == null) {
          ref.read(_selectedPetProvider.notifier).set(pets.first);
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

                  // ── Pets card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    decoration:
                        AppTheme.cardDecoration(color: AppTheme.surface),
                    child: Column(
                      children: [
                        // Header row: title + Add Pet button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Pets Dashboard',
                                style: AppTheme.sectionHeading()),
                            GestureDetector(
                              onTap: () => _showAddPetSheet(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingM,
                                  vertical: AppTheme.spacingXS,
                                ),
                                decoration: AppTheme.pillDecoration(
                                    color: AppTheme.electricSky),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add,
                                        size: 14,
                                        color: AppTheme.midnightPlum),
                                    const SizedBox(width: 4),
                                    Text('Add Pet',
                                        style: AppTheme.caption()),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        petsAsync.when(
                          loading: () => const CircularProgressIndicator(
                              color: AppTheme.softIris),
                          error: (_, __) => Text('Could not load pets.',
                              style: AppTheme.caption(
                                  color: AppTheme.statusRejected)),
                          data: (pets) => pets.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: AppTheme.spacingL),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.pets,
                                          size: 40,
                                          color: AppTheme.softIris),
                                      const SizedBox(
                                          height: AppTheme.spacingS),
                                      Text(
                                        'No pets yet!',
                                        style: AppTheme.sectionHeading(),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                          height: AppTheme.spacingXS),
                                      Text(
                                        'Tap Add Pet to get started.',
                                        style: AppTheme.caption(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : _PetsRow(pets: pets),
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
    final selectedPet = ref.watch(_selectedPetProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: pets.map((pet) {
          final isSelected = selectedPet?.petId == pet.petId;
          return GestureDetector(
            onTap: () => ref.read(_selectedPetProvider.notifier).set(pet),
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
    final selectedPet = ref.watch(_selectedPetProvider);
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
                style: AppTheme.caption(color: AppTheme.statusRejected)),
          ),
          data: (allTasks) {
            final petTasks =
                allTasks.where((t) => t.petId == selectedPet.petId).toList();

            if (petTasks.isEmpty) {
              return Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
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
      case 'completed':       return 'Completed';
      case 'pending_approval': return 'Pending';
      case 'todo':            return 'To Do';
      default:                return task.status;
    }
  }

  Color get _statusColor {
    switch (task.status) {
      case 'completed':        return AppTheme.statusCompleted;
      case 'pending_approval': return AppTheme.statusPending;
      default:                 return AppTheme.midnightPlum;
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
                Text('Task: ${task.title}',
                    style: AppTheme.body(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('Assigned to: $_assignedNames',
                    style: AppTheme.caption(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('Status: $_statusLabel',
                    style: AppTheme.caption(color: _statusColor)),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    TasksDashboardScreen(highlightTaskId: task.taskId),
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
    final selectedPet = ref.watch(_selectedPetProvider);
    if (selectedPet == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration(color: AppTheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  decoration:
                      AppTheme.pillDecoration(color: AppTheme.electricSky),
                  child: Text('Edit Pet', style: AppTheme.caption()),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'Pet Name', value: selectedPet.name),
                    _InfoRow(label: 'Species',  value: selectedPet.type),
                    _InfoRow(label: 'Breed',    value: selectedPet.breed),
                    _InfoRow(label: 'Gender',   value: selectedPet.gender),
                    _InfoRow(label: 'Age',      value: '${selectedPet.age}'),
                    _InfoRow(label: 'Pet License', value: selectedPet.petLicense),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vet Info', style: AppTheme.body()),
                    const SizedBox(height: AppTheme.spacingXS),
                    _InfoRow(label: 'Dr. Name',    value: selectedPet.veterinarian),
                    _InfoRow(label: 'Vet Address', value: selectedPet.vetOffice),
                    _InfoRow(label: 'Vet Phone',   value: selectedPet.vetNumber),
                    _InfoRow(label: 'Pet Meds',    value: selectedPet.petMeds),
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

// ─── Shared form field builder ────────────────────────────────────────────────

Widget _buildField(
  String hint,
  TextEditingController controller, {
  TextInputType keyboard = TextInputType.text,
}) {
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

// ─── Shared bottom sheet handle ───────────────────────────────────────────────

Widget _sheetHandle() => Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.softIris,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
      ),
    );

// ─── Shared pet type selector ─────────────────────────────────────────────────

Widget _typeSelector(
    String selected, void Function(String) onSelect) {
  const types = ['Dog', 'Cat', 'Hamster'];
  return Wrap(
    spacing: AppTheme.spacingXS,
    children: types.map((t) {
      final isSelected = selected == t;
      return GestureDetector(
        onTap: () => onSelect(t),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.softIris : AppTheme.electricSky,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Text(t, style: AppTheme.caption()),
        ),
      );
    }).toList(),
  );
}

// ─── Add Pet Bottom Sheet ─────────────────────────────────────────────────────

class _AddPetSheet extends ConsumerStatefulWidget {
  const _AddPetSheet();

  @override
  ConsumerState<_AddPetSheet> createState() => _AddPetSheetState();
}

class _AddPetSheetState extends ConsumerState<_AddPetSheet> {
  final _nameCtrl        = TextEditingController();
  final _breedCtrl       = TextEditingController();
  final _genderCtrl      = TextEditingController();
  final _ageCtrl         = TextEditingController();
  final _licenseCtrl     = TextEditingController();
  final _vetNameCtrl     = TextEditingController();
  final _vetAddressCtrl  = TextEditingController();
  final _vetPhoneCtrl    = TextEditingController();
  final _petMedsCtrl     = TextEditingController();
  String _selectedType   = 'Dog';

  @override
  void dispose() {
    for (final c in [_nameCtrl, _breedCtrl, _genderCtrl, _ageCtrl,
        _licenseCtrl, _vetNameCtrl, _vetAddressCtrl, _vetPhoneCtrl,
        _petMedsCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a pet name.',
            style: AppTheme.caption(color: AppTheme.surface)),
        backgroundColor: AppTheme.statusRejected,
      ));
      return;
    }

    final familyId = ref.read(userProvider).user?.familyId ?? '';
    if (familyId.isEmpty) return;

    final pet = PetModel(
      petId:        '',
      familyId:     familyId,
      name:         name,
      type:         _selectedType.toLowerCase(),
      breed:        _breedCtrl.text.trim(),
      gender:       _genderCtrl.text.trim(),
      age:          int.tryParse(_ageCtrl.text.trim()) ?? 0,
      petLicense:   _licenseCtrl.text.trim(),
      veterinarian: _vetNameCtrl.text.trim(),
      vetOffice:    _vetAddressCtrl.text.trim(),
      vetNumber:    _vetPhoneCtrl.text.trim(),
      petMeds:      _petMedsCtrl.text.trim(),
    );

    await ref.read(petProvider.notifier).createPet(pet);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(petProvider).isLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingXL, AppTheme.spacingXL,
        AppTheme.spacingXL,
        MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingXL,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sheetHandle(),
            const SizedBox(height: AppTheme.spacingL),
            Text('Add Pet', style: AppTheme.sectionHeading()),
            const SizedBox(height: AppTheme.spacingM),
            _typeSelector(_selectedType,
                (t) => setState(() => _selectedType = t)),
            const SizedBox(height: AppTheme.spacingM),
            _buildField('Pet Name *', _nameCtrl),
            _buildField('Breed', _breedCtrl),
            _buildField('Gender', _genderCtrl),
            _buildField('Age', _ageCtrl, keyboard: TextInputType.number),
            _buildField('Pet License', _licenseCtrl),
            Text('Vet Info', style: AppTheme.body()),
            const SizedBox(height: AppTheme.spacingS),
            _buildField('Dr. Name', _vetNameCtrl),
            _buildField('Vet Address', _vetAddressCtrl),
            _buildField('Vet Phone', _vetPhoneCtrl,
                keyboard: TextInputType.phone),
            _buildField('Pet Meds', _petMedsCtrl),
            ElevatedButton(
              onPressed: isLoading ? null : _save,
              style: AppTheme.elevatedButtonStyle,
              child: isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.midnightPlum))
                  : Text('Add Pet', style: AppTheme.buttonText()),
            ),
          ],
        ),
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
  late final TextEditingController _nameCtrl;
  late final TextEditingController _breedCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _licenseCtrl;
  late final TextEditingController _vetNameCtrl;
  late final TextEditingController _vetAddressCtrl;
  late final TextEditingController _vetPhoneCtrl;
  late final TextEditingController _petMedsCtrl;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _nameCtrl       = TextEditingController(text: widget.pet.name);
    _breedCtrl      = TextEditingController(text: widget.pet.breed);
    _genderCtrl     = TextEditingController(text: widget.pet.gender);
    _ageCtrl        = TextEditingController(text: '${widget.pet.age}');
    _licenseCtrl    = TextEditingController(text: widget.pet.petLicense);
    _vetNameCtrl    = TextEditingController(text: widget.pet.veterinarian);
    _vetAddressCtrl = TextEditingController(text: widget.pet.vetOffice);
    _vetPhoneCtrl   = TextEditingController(text: widget.pet.vetNumber);
    _petMedsCtrl    = TextEditingController(text: widget.pet.petMeds);
    _selectedType   = ['Dog', 'Cat', 'Hamster'].firstWhere(
      (t) => t.toLowerCase() == widget.pet.type.toLowerCase(),
      orElse: () => 'Dog',
    );
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _breedCtrl, _genderCtrl, _ageCtrl,
        _licenseCtrl, _vetNameCtrl, _vetAddressCtrl, _vetPhoneCtrl,
        _petMedsCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(petProvider.notifier).updatePet(widget.pet.petId, {
      'name':         _nameCtrl.text.trim(),
      'type':         _selectedType.toLowerCase(),
      'breed':        _breedCtrl.text.trim(),
      'gender':       _genderCtrl.text.trim(),
      'age':          int.tryParse(_ageCtrl.text.trim()) ?? 0,
      'pet_license':  _licenseCtrl.text.trim(),
      'veterinarian': _vetNameCtrl.text.trim(),
      'vet_office':   _vetAddressCtrl.text.trim(),
      'vet_number':   _vetPhoneCtrl.text.trim(),
      'pet_meds':     _petMedsCtrl.text.trim(),
    });
    if (mounted) {
      ref.read(_selectedPetProvider.notifier).set(null);
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    await ref.read(petProvider.notifier).deletePet(widget.pet.petId);
    if (mounted) {
      ref.read(_selectedPetProvider.notifier).set(null);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(petProvider).isLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingXL, AppTheme.spacingXL,
        AppTheme.spacingXL,
        MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingXL,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sheetHandle(),
            const SizedBox(height: AppTheme.spacingL),
            Text('Edit Pet', style: AppTheme.sectionHeading()),
            const SizedBox(height: AppTheme.spacingM),
            _typeSelector(_selectedType,
                (t) => setState(() => _selectedType = t)),
            const SizedBox(height: AppTheme.spacingM),
            _buildField('Pet Name', _nameCtrl),
            _buildField('Breed', _breedCtrl),
            _buildField('Gender', _genderCtrl),
            _buildField('Age', _ageCtrl, keyboard: TextInputType.number),
            _buildField('Pet License', _licenseCtrl),
            Text('Vet Info', style: AppTheme.body()),
            const SizedBox(height: AppTheme.spacingS),
            _buildField('Dr. Name', _vetNameCtrl),
            _buildField('Vet Address', _vetAddressCtrl),
            _buildField('Vet Phone', _vetPhoneCtrl,
                keyboard: TextInputType.phone),
            _buildField('Pet Meds', _petMedsCtrl),
            ElevatedButton(
              onPressed: isLoading ? null : _save,
              style: AppTheme.elevatedButtonStyle,
              child: isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.midnightPlum))
                  : Text('Save Changes', style: AppTheme.buttonText()),
            ),
            const SizedBox(height: AppTheme.spacingM),
            ElevatedButton(
              onPressed: isLoading ? null : _delete,
              style: AppTheme.destructiveButtonStyle,
              child: Text('Delete Pet',
                  style: AppTheme.buttonText(
                      color: AppTheme.statusRejected)),
            ),
          ],
        ),
      ),
    );
  }
}