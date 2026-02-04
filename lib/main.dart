import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Replaced Provider with Riverpod
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Riverpod requires ProviderScope at the root
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

// --- MODELS ---
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

// --- SERVICE LAYER ---
class PetService {
  final CollectionReference<Map<String, dynamic>> _pets =
      FirebaseFirestore.instance.collection('pets');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPets() =>
      _pets.orderBy('name').snapshots();

  Future<void> savePet(Map<String, dynamic> data, {String? docId}) async {
    final batch = FirebaseFirestore.instance.batch();
    if (docId == null) {
      final newDoc = _pets.doc();
      batch.set(newDoc, {...data, 'createdAt': FieldValue.serverTimestamp()});
    } else {
      batch.update(_pets.doc(docId), {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> deletePet(String docId) async {
    await _pets.doc(docId).delete();
  }
}

// --- RIVERPOD STATE MANAGEMENT ---

// This replaces your PetState class
class PetOperationState {
  final Set<String> pendingOperations;
  final bool hasUnsavedChanges;

  PetOperationState({
    this.pendingOperations = const {},
    this.hasUnsavedChanges = false,
  });

  bool get hasPending => pendingOperations.isNotEmpty;

  PetOperationState copyWith({Set<String>? pendingOperations, bool? hasUnsavedChanges}) {
    return PetOperationState(
      pendingOperations: pendingOperations ?? this.pendingOperations,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

class PetNotifier extends StateNotifier<PetOperationState> {
  PetNotifier() : super(PetOperationState());

  void startOperation(String opId) {
    final newSet = Set<String>.from(state.pendingOperations)..add(opId);
    state = state.copyWith(pendingOperations: newSet, hasUnsavedChanges: true);
  }

  void endOperation(String opId) {
    final newSet = Set<String>.from(state.pendingOperations)..remove(opId);
    state = state.copyWith(
      pendingOperations: newSet,
      hasUnsavedChanges: newSet.isNotEmpty,
    );
  }
}

// The global provider
final petProvider = StateNotifierProvider<PetNotifier, PetOperationState>((ref) {
  return PetNotifier();
});

// --- UI COMPONENTS ---

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PetService _petService = PetService();

  void _showPetForm([Pet? pet, String? docId]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PetFormDialog(
        pet: pet,
        onSubmit: (data) async {
          final opId = DateTime.now().millisecondsSinceEpoch.toString();
          ref.read(petProvider.notifier).startOperation(opId);

          try {
            await _petService.savePet(data, docId: docId);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Success!'), backgroundColor: Colors.green),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          } finally {
            ref.read(petProvider.notifier).endOperation(opId);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the riverpod state
    final petState = ref.watch(petProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tail Home'),
        actions: [
          if (petState.hasPending)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _petService.streamPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final pet = Pet.fromFirestore(docs[index]);
              return ListTile(
                title: Text(pet.name),
                subtitle: Text(pet.breed),
                onTap: () => _showPetForm(pet, docs[index].id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPetForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// (Rest of your screens: HealthTrackerScreen, PetProfileScreen, PetFormDialog, MainNavigationScreen remain largely the same, but change MainNavigationScreen to ConsumerStatefulWidget if it needs the provider)

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

// REUSABLE FORM DIALOG
class PetFormDialog extends StatefulWidget {
  final Pet? pet;
  final Function(Map<String, dynamic>) onSubmit;
  const PetFormDialog({super.key, this.pet, required this.onSubmit});

  @override
  State<PetFormDialog> createState() => _PetFormDialogState();
}

class _PetFormDialogState extends State<PetFormDialog> {
  final _formKey = GlobalKey<FormState>();
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
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextFormField(controller: _breedController, decoration: const InputDecoration(labelText: 'Breed')),
            TextFormField(controller: _ageController, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
          ],
        ),
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

class HealthTrackerScreen extends StatelessWidget { const HealthTrackerScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Health Tracker'))); }
class PetProfileScreen extends StatelessWidget { const PetProfileScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Pet Profiles'))); }