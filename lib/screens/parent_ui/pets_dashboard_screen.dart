import 'package:flutter/material.dart';
import 'package:habit_tail/theme/app_theme.dart';

class PetsDashboardScreen extends StatefulWidget {
  const PetsDashboardScreen({super.key});

  @override
  State<PetsDashboardScreen> createState() => _PetsDashboardScreenState();
}

class _PetsDashboardScreenState extends State<PetsDashboardScreen> {
  // TODO: Replace hardcoded pets with real data from Firestore
  // Query pets collection where family_id matches
  final List<Map<String, dynamic>> _pets = [
    {
      'name': 'Rexy',
      'image': null, // TODO: Replace with real image asset/url
      'species': 'Dog',
      'breed': 'Labrador',
      'gender': 'Male',
      'age': '3',
      'license': 'ABC123',
      'drName': 'Dr. Smith',
      'vetAddress': '123 Vet St',
      'vetPhone': '555-1234',
      'vetMeds': 'None',
    },
    {
      'name': 'Tim',
      'image': null,
      'species': 'Cat',
      'breed': 'Siamese',
      'gender': 'Male',
      'age': '2',
      'license': 'DEF456',
      'drName': 'Dr. Jones',
      'vetAddress': '456 Vet Ave',
      'vetPhone': '555-5678',
      'vetMeds': 'None',
    },
    {
      'name': 'Lazy',
      'image': null,
      'species': 'Cat',
      'breed': 'Persian',
      'gender': 'Female',
      'age': '5',
      'license': 'GHI789',
      'drName': 'Dr. Brown',
      'vetAddress': '789 Vet Blvd',
      'vetPhone': '555-9012',
      'vetMeds': 'Allergy meds',
    },
  ];

  // TODO: Replace hardcoded tasks with real data from Firestore
  // Query tasks collection where pet matches selected pet and family_id matches
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Feed Pet', 'pet': 'Rexy', 'assignedTo': 'Tommy', 'status': 'Completed'},
    {'title': 'Feed Pet', 'pet': 'Rexy', 'assignedTo': 'Tommy', 'status': 'Completed'},
    {'title': 'Feed Pet', 'pet': 'Rexy', 'assignedTo': 'Tommy', 'status': 'Pending'},
    {'title': 'Feed Pet', 'pet': 'Rexy', 'assignedTo': 'Tommy', 'status': 'Pending'},
  ];

  int _selectedPetIndex = 0;
  bool _isEditingPet = false;

  // Edit controllers
  late TextEditingController _petNameController;
  late TextEditingController _speciesController;
  late TextEditingController _breedController;
  late TextEditingController _genderController;
  late TextEditingController _ageController;
  late TextEditingController _licenseController;
  late TextEditingController _drNameController;
  late TextEditingController _vetAddressController;
  late TextEditingController _vetPhoneController;
  late TextEditingController _vetMedsController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final pet = _pets[_selectedPetIndex];
    _petNameController = TextEditingController(text: pet['name']);
    _speciesController = TextEditingController(text: pet['species']);
    _breedController = TextEditingController(text: pet['breed']);
    _genderController = TextEditingController(text: pet['gender']);
    _ageController = TextEditingController(text: pet['age']);
    _licenseController = TextEditingController(text: pet['license']);
    _drNameController = TextEditingController(text: pet['drName']);
    _vetAddressController = TextEditingController(text: pet['vetAddress']);
    _vetPhoneController = TextEditingController(text: pet['vetPhone']);
    _vetMedsController = TextEditingController(text: pet['vetMeds']);
  }

  void _switchPet(int index) {
    setState(() {
      _selectedPetIndex = index;
      _isEditingPet = false;
      _disposeControllers();
      _initControllers();
    });
  }

  void _disposeControllers() {
    _petNameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    _licenseController.dispose();
    _drNameController.dispose();
    _vetAddressController.dispose();
    _vetPhoneController.dispose();
    _vetMedsController.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPet = _pets[_selectedPetIndex];
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
                  _buildPetSelector(),
                  const SizedBox(height: 20),
                  Text('${selectedPet['name']}\'s Dashboard',
                      style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildTasksList(),
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

  Widget _buildHeader() {
    // TODO: Replace 'Sandra' with real parent display_name from Firestore
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
              Text('Sandra!', style: AppTheme.bodyText(fontSize: 24, fontWeight: FontWeight.bold)),
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

  Widget _buildPetSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_pets.length, (index) {
        final pet = _pets[index];
        final bool isSelected = _selectedPetIndex == index;
        return GestureDetector(
          onTap: () => _switchPet(index),
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
                  // TODO: Replace with real pet image from Firestore storage
                  child: const Icon(Icons.pets, color: AppTheme.midnightPlum),
                ),
                const SizedBox(height: 5),
                Text(pet['name'],
                    style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTasksList() {
    // TODO: Filter tasks by selected pet from Firestore
    final petTasks = _tasks.where((t) => t['pet'] == _pets[_selectedPetIndex]['name']).toList();
    return Column(
      children: petTasks.map((task) => _buildTaskCard(task)).toList(),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final bool isCompleted = task['status'] == 'Completed';
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
                Text('Task: ${task['title']}',
                    style: AppTheme.bodyText(fontSize: 11, fontWeight: FontWeight.bold)),
                Text('Pet: ${task['pet']}', style: AppTheme.bodyText(fontSize: 10)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assigned to:', style: AppTheme.bodyText(fontSize: 10)),
                Text(task['assignedTo'],
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
                  task['status'],
                  style: AppTheme.bodyText(fontSize: 11, fontWeight: FontWeight.bold).copyWith(
                    color: isCompleted ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to Tasks Dashboard and open edit modal for this task
              Navigator.pop(context);
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

  Widget _buildPetInfoSection(Map<String, dynamic> pet) {
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
              // Pet Info Column
              Expanded(
                child: Column(
                  children: [
                    _buildInfoField('Pet Name:', _petNameController),
                    _buildInfoField('Species:', _speciesController),
                    _buildInfoField('Breed:', _breedController),
                    _buildInfoField('Gender:', _genderController),
                    _buildInfoField('Age:', _ageController),
                    _buildInfoField('Pet License:', _licenseController),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Vet Info Column
              Expanded(
                child: Column(
                  children: [
                    _buildInfoField('Dr. Name:', _drNameController),
                    _buildInfoField('Vet Address:', _vetAddressController),
                    _buildInfoField('Vet Phone:', _vetPhoneController),
                    _buildInfoField('Vet Meds:', _vetMedsController),
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
              onTap: () {
                // TODO: Update pet document in Firestore with new values
                setState(() => _isEditingPet = false);
              },
            ),
            const SizedBox(height: 8),
            AppTheme.buildButton(
              context: context,
              label: 'Delete Pet',
              onTap: () => _showDeletePetDialog(),
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

  void _showDeletePetDialog() {
    final petName = _pets[_selectedPetIndex]['name'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $petName?',
            style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
          'This will permanently delete $petName and all associated tasks.',
          style: AppTheme.bodyText(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.bodyText(fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Delete pet document from Firestore
              // - Delete all tasks associated with this pet
              // - Remove pet from family's pet list
              Navigator.pop(context);
              setState(() {
                _pets.removeAt(_selectedPetIndex);
                _selectedPetIndex = 0;
                if (_pets.isNotEmpty) _initControllers();
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