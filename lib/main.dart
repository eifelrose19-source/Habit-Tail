import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ==========================================
// 1. GLOBAL PROVIDERS (The Final Connection)
// ==========================================

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) => UserNotifier());
final petProvider = StateNotifierProvider<PetNotifier, List<Pet>>((ref) => PetNotifier());
final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) => TaskNotifier());

// ==========================================
// 2. MAIN ENTRY POINT
// ==========================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// ==========================================
// 3. MODELS (The Blueprints)
// ==========================================

class UserModel {
  final String userId;
  final String childId;
  final String familyId;
  final String name;
  final String parentId;
  final int totalPoints;

  UserModel({
    required this.userId,
    required this.childId,
    required this.familyId,
    required this.name,
    required this.parentId,
    required this.totalPoints,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      userId: doc.id,
      childId: data['Child_id'] ?? "",
      familyId: data['Family_id'] ?? "",
      name: data['Name'] ?? "",
      parentId: data['Parent_id'] ?? "",
      totalPoints: (data['Total_points'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'Child_id': childId,
    'Family_id': familyId,
    'Name': name,
    'Parent_id': parentId,
    'Total_points': totalPoints,
  };
}

class UserState {
  final UserModel? user;
  final bool isLoading;
  const UserState({this.user, this.isLoading = false});
  UserState copyWith({UserModel? user, bool? isLoading}) => 
      UserState(user: user ?? this.user, isLoading: isLoading ?? this.isLoading);
}

class Pet {
  final String id;
  final String name;
  final String breed;
  final int age;

  Pet({required this.id, required this.name, required this.breed, required this.age});

  factory Pet.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Pet(
      id: doc.id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      age: data['age'] ?? 0,
    );
  }
}

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final int points;

  Task({required this.id, required this.title, this.isCompleted = false, required this.points});

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      points: data['points'] ?? 0,
    );
  }
}

// ==========================================
// 4. NOTIFIERS (The Logic Managers)
// ==========================================

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());
  final _db = FirebaseFirestore.instance;

  void watchUser(String uid) {
    state = state.copyWith(isLoading: true);
    _db.collection('Users').doc(uid).snapshots().listen((doc) {
      if (doc.exists) {
        state = state.copyWith(user: UserModel.fromFirestore(doc), isLoading: false);
      }
    });
  }

  Future<void> addPoints(int points) async {
    if (state.user == null) return;
    final newTotal = state.user!.totalPoints + points;
    await _db.collection('Users').doc(state.user!.userId).update({'Total_points': newTotal});
  }
}

class PetNotifier extends StateNotifier<List<Pet>> {
  PetNotifier() : super([]);
  final _db = FirebaseFirestore.instance;

  void watchPets() {
    _db.collection('pets').orderBy('name').snapshots().listen((snapshot) {
      state = snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
    });
  }

  Future<void> savePet(Map<String, dynamic> data, {String? docId}) async {
    if (docId == null) {
      await _db.collection('pets').add({...data, 'createdAt': FieldValue.serverTimestamp()});
    } else {
      await _db.collection('pets').doc(docId).update({...data, 'updatedAt': FieldValue.serverTimestamp()});
    }
  }
}

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);
  final _db = FirebaseFirestore.instance;

  void watchTasks() {
    _db.collection('tasks').snapshots().listen((snapshot) {
      state = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }
}

// ==========================================
// 5. UI COMPONENTS & NAVIGATION
// ==========================================

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = [HomeScreen(), HealthTrackerScreen(), PetProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.health_and_safety_rounded), label: 'Health'),
          NavigationDestination(icon: Icon(Icons.pets_rounded), label: 'Pets'),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showPetForm(BuildContext context, WidgetRef ref, [Pet? pet, String? docId]) {
    showDialog(
      context: context,
      builder: (context) => PetFormDialog(
        pet: pet,
        onSubmit: (data) => ref.read(petProvider.notifier).savePet(data, docId: docId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petProvider);
    final userState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(userState.user?.name ?? 'Habit Tail Home'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Points: ${userState.user?.totalPoints ?? 0}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: pets.isEmpty 
          ? const Center(child: Text("No pets found. Add one!"))
          : ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(pet.name),
                  subtitle: Text(pet.breed),
                  onTap: () => _showPetForm(context, ref, pet, pet.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPetForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- REUSABLE DIALOGS & PLACEHOLDERS ---

class PetFormDialog extends StatefulWidget {
  final Pet? pet;
  final Function(Map<String, dynamic>) onSubmit;
  const PetFormDialog({super.key, this.pet, required this.onSubmit});

  @override
  State<PetFormDialog> createState() => _PetFormDialogState();
}

class _PetFormDialogState extends State<PetFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet?.name ?? '');
    _breedController = TextEditingController(text: widget.pet?.breed ?? '');
    _ageController = TextEditingController(text: widget.pet?.age.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.pet == null ? 'Add Pet' : 'Edit Pet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: _breedController, decoration: const InputDecoration(labelText: 'Breed')),
          TextField(controller: _ageController, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit({
              'name': _nameController.text,
              'breed': _breedController.text,
              'age': int.tryParse(_ageController.text) ?? 0,
            });
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class HealthTrackerScreen extends StatelessWidget { const HealthTrackerScreen({super.key}); @override Widget build(BuildContext context) => const Center(child: Text('Health Tracker Screen')); }
class PetProfileScreen extends StatelessWidget { const PetProfileScreen({super.key}); @override Widget build(BuildContext context) => const Center(child: Text('Pet Profile Screen')); }