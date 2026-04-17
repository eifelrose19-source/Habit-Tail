import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tail/theme/app_theme.dart';
import 'package:habit_tail/services/auth_service.dart';
import 'package:habit_tail/models/pet_model.dart';
import 'package:habit_tail/models/task_model.dart'; 
import 'package:habit_tail/providers/pet_provider.dart'; 
import 'package:habit_tail/providers/task_provider.dart'; 
import 'package:habit_tail/screens/parent_ui/tasks_dashboard_screen.dart';

class PetsDashboardScreen extends ConsumerStatefulWidget {
  const PetsDashboardScreen({super.key});

  @override
  ConsumerState<PetsDashboardScreen> createState() => _PetsDashboardScreenState();
}

class _PetsDashboardScreenState extends ConsumerState<PetsDashboardScreen> {
  final AuthService _authService = AuthService();

  int _selectedPetIndex = 0;
  bool _isEditingPet = false;
  String? _familyId;

  late TextEditingController _petNameController;
  late TextEditingController _typeController;
  late TextEditingController _breedController;
  late TextEditingController _genderController;
  late TextEditingController _ageController;
  late TextEditingController _petLicenseController;
  late TextEditingController _veterinarianController;
  late TextEditingController _vetOfficeController;
  late TextEditingController _vetNumberController;
  late TextEditingController _petMedsController;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _fetchFamilyId();
  }

  void _initControllers() {
    _petNameController = TextEditingController();
    _typeController = TextEditingController();
    _breedController = TextEditingController();
    _genderController = TextEditingController();
    _ageController = TextEditingController();
    _petLicenseController = TextEditingController();
    _veterinarianController = TextEditingController();
    _vetOfficeController = TextEditingController();
    _vetNumberController = TextEditingController();
    _petMedsController = TextEditingController();
  }

  Future<void> _fetchFamilyId() async {
    final user = _authService.currentUser;
    if (user != null) {
      final token = await user.getIdTokenResult();
      final id = token.claims?['family_id'] as String?; 
      if (!mounted) return;
      setState(() {
        _familyId = id; 
      });

      if (id != null) { 
        ref.read(petProvider.notifier).watchFamilyPets(id); 
        ref.read(taskProvider.notifier).watchFamilyTasks(id); 
      }
    }
  }

  void _updateControllers(PetModel pet) {
    if (_isEditingPet) return;

    _petNameController.text = pet.name;
    _typeController.text = pet.type;
    _breedController.text = pet.breed;
    _genderController.text = pet.gender;
    _ageController.text = pet.age.toString();
    _petLicenseController.text = pet.petLicense;
    _veterinarianController.text = pet.veterinarian;
    _vetOfficeController.text = pet.vetOffice;
    _vetNumberController.text = pet.vetNumber;
    _petMedsController.text = pet.petMeds;
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _typeController.dispose();
    _breedController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    _petLicenseController.dispose();
    _veterinarianController.dispose();
    _vetOfficeController.dispose();
    _vetNumberController.dispose();
    _petMedsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_familyId == null) {
      return const Scaffold(
        backgroundColor: AppTheme.beigeBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pets = ref.watch(petProvider);

    if (pets.isEmpty) { 
      return _buildEmptyState();
    }

    if (_selectedPetIndex >= pets.length) _selectedPetIndex = 0;
    final selectedPet = pets[_selectedPetIndex];

    _updateControllers(selectedPet);

    return Scaffold(
      backgroundColor: AppTheme.beigeBackground,
      body: Column( 
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text('Pets Dashboard',
                      style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildPetSelector(pets),
                  const SizedBox(height: 20),
                  Text('${selectedPet.name}\'s Dashboard',
                      style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildTasksList(selectedPet.name),
                  const SizedBox(height: 20),
                  _buildPetInfoSection(selectedPet),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: Text('No pets registered yet.',
                style: AppTheme.bodyText(fontSize: 16)),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildHeader() {
    final String parentName = _authService.currentUser?.displayName ?? 'User';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 25, right: 25),
      decoration: AppTheme.backgroundGradient,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome,', style: AppTheme.bodyText(fontSize: 18)),
              Text('$parentName!', style: AppTheme.bodyText(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              _buildHeaderIcon(Icons.group, "Family"),
              const SizedBox(width: 15),
              _buildHeaderIcon(Icons.settings, "Settings"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.midnightPlum, size: 28),
        Text(label, style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPetSelector(List<PetModel> pets) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(pets.length, (index) {
        final pet = pets[index];
        final bool isSelected = _selectedPetIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPetIndex = index;
              _isEditingPet = false;
            });
          },
          child: Container(
            width: 90,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.softIris : AppTheme.electricSky,
              borderRadius: BorderRadius.circular(15),
              border: isSelected
                  ? Border.all(color: AppTheme.midnightPlum, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.pets, color: AppTheme.midnightPlum),
                ),
                const SizedBox(height: 5),
                Text(pet.name,
                    style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTasksList(String petName) {
    final allTasks = ref.watch(taskProvider);
    final petTasks = allTasks.where((task) => task.title.contains(petName)).toList();

    if (petTasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text("No upcoming tasks for $petName",
            style: AppTheme.bodyText(fontSize: 12).copyWith(color: Colors.grey)),
      );
    }

    return Column(
      children: petTasks.map((task) => _buildTaskCard(task, petName)).toList(),
    );
  }
  Widget _buildTaskCard(TaskModel task, String petName) {
    final bool isCompleted = task.status == 'completed'; 
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.electricSky,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Task: ${task.title}', 
                    style: AppTheme.bodyText(fontSize: 11, fontWeight: FontWeight.bold)),
                Text('Pet: $petName', style: AppTheme.bodyText(fontSize: 10)), 
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assigned to:', style: AppTheme.bodyText(fontSize: 10)),
                Text(task.assignedTo.isEmpty ? 'Everyone' : task.assignedTo, 
                    style: AppTheme.bodyText(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status:', style: AppTheme.bodyText(fontSize: 10)),
                Text(
                  task.status.toUpperCase(), 
                  style: AppTheme.bodyText(fontSize: 11, fontWeight: FontWeight.bold).copyWith(
                    color: isCompleted ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TasksDashboardScreen()),
              );
            },
            style: AppTheme.elevatedButtonStyle.copyWith(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
            ),
            child: Text('Edit Task',
                style: AppTheme.bodyText(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInfoSection(PetModel pet) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.electricSky.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pet Info',
                  style: AppTheme.bodyText(fontSize: 14, fontWeight: FontWeight.bold)),
              Text('Vet Info',
                  style: AppTheme.bodyText(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildInfoField('Pet Name:', _petNameController),
                    _buildInfoField('Type:', _typeController),
                    _buildInfoField('Breed:', _breedController),
                    _buildInfoField('Gender:', _genderController),
                    _buildInfoField('Age:', _ageController),
                    _buildInfoField('Pet License:', _petLicenseController),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    _buildInfoField('Veterinarian:', _veterinarianController),
                    _buildInfoField('Vet Office:', _vetOfficeController),
                    _buildInfoField('Vet Phone:', _vetNumberController),
                    _buildInfoField('Vet Meds:', _petMedsController),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isEditingPet) ...[
            AppTheme.buildButton(
              context: context,
              label: 'Save Changes',
              onTap: () async {
                await ref.read(petServiceProvider).updatePetRaw(pet.petId, {
                  'name': _petNameController.text,
                  'type': _typeController.text,
                  'breed': _breedController.text,
                  'gender': _genderController.text,
                  'age': int.tryParse(_ageController.text) ?? 0,
                  'pet_license': _petLicenseController.text,
                  'veterinarian': _veterinarianController.text,
                  'vet_office': _vetOfficeController.text,
                  'vet_number': _vetNumberController.text,
                  'pet_meds': _petMedsController.text,
                });
                if (!mounted) return;
                setState(() => _isEditingPet = false);
              },
            ),
            const SizedBox(height: 8),
            AppTheme.buildButton(
              context: context,
              label: 'Delete Pet',
              onTap: () => _showDeletePetDialog(pet),
            ),
          ] else
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => setState(() => _isEditingPet = true),
                style: AppTheme.elevatedButtonStyle,
                child: Text('Edit Pet',
                    style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: _isEditingPet
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: label,
                      labelStyle: AppTheme.bodyText(fontSize: 10),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: AppTheme.bodyText(fontSize: 11),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTheme.bodyText(fontSize: 10)),
                      Text(controller.text,
                          style: AppTheme.bodyText(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showDeletePetDialog(PetModel pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${pet.name}?',
            style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
          'This will permanently delete ${pet.name} and all associated tasks.',
          style: AppTheme.bodyText(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.bodyText(fontSize: 14)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(petServiceProvider).deletePetAndTasks(pet.petId, pet.name);

              if (!context.mounted) return;

              Navigator.of(context).pop();
              setState(() {
                _selectedPetIndex = 0;
                _isEditingPet = false;
              });
            },
            child: Text('Delete',
                style: AppTheme.bodyText(fontSize: 14, fontWeight: FontWeight.bold)
                    .copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.irisLight, AppTheme.softIris],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppTheme.midnightPlum),
          ),
        ],
      ),
    );
  }
}