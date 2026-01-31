import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => PetState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tail',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

/// MODEL (Pet)
class Pet {
  final String id;
  final String name;
  final String breed;
  final int age;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
  });

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

/// SERVICE LAYER for Firestore
class PetService {
  final CollectionReference<Map<String, dynamic>> _pets =
      FirebaseFirestore.instance.collection('pets');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPets() =>
      _pets.orderBy('name').snapshots();
///Uses a batch to ensure that if we added multiple metadata fields, the write would be automatic.
  Future<void> savePet(Map<String, dynamic> data, {String? docId}) async {
    final batch = FirebaseFirestore.instance.batch();
    if (docId == null) {
      final newDoc = _pets.doc();
      batch.set(newDoc, {...data, 'createdAt': FieldValue.serverTimestamp()});
    } else {
      batch.update(_pets.doc(docId), {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
        //consistency across different time zones and device settings.
      });
    }
    await batch.commit();
  }

  Future<void> deletePet(String docId) async {
    await _pets.doc(docId).delete();
  }
}

/// STATE MANAGEMENT for pending operations / unsaved changes
/// Tracks IDs of active Firebase tasks to show a global loading indicator
class PetState extends ChangeNotifier {
  final Set<String> _pendingOperations = {};
  bool _hasUnsavedChanges = false;

  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get hasPending => _pendingOperations.isNotEmpty;
//concurrent Firestore writes. The UI will show a loading spinnder as long as the Set is not empty.
  void startOperation(String opId) {
    _pendingOperations.add(opId);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void endOperation(String opId) {
    _pendingOperations.remove(opId);
    _hasUnsavedChanges = _pendingOperations.isNotEmpty;
    notifyListeners();
  }
}

/// LIFECYCLE OBSERVER
class _LifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onPause;

  _LifecycleObserver({required this.onPause});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      onPause();
    }
  }
}

/// PET FORM DIALOG (Reusable)
class PetFormDialog extends StatefulWidget {
  final Pet? pet;
  final Function(Map<String, dynamic>) onSubmit;

  const PetFormDialog({super.key, this.pet, required this.onSubmit});

  @override
  State<PetFormDialog> createState() => _PetFormDialogState();
}

class _PetFormDialogState extends State<PetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data or empty strings
    _nameController = TextEditingController(text: widget.pet?.name ?? '');
    _breedController = TextEditingController(text: widget.pet?.breed ?? '');
    _ageController =
        TextEditingController(text: widget.pet?.age.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.pet == null;

    return AlertDialog(
      title: Text(isNew ? 'Add New Pet' : 'Edit ${widget.pet!.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pet Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a name' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // Breed Field
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Age Field
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit({
                'name': _nameController.text.trim(),
                'breed': _breedController.text.trim(),
                'age': int.tryParse(_ageController.text.trim()) ?? 0,
              });
              Navigator.pop(context);
            }
          },
          child: Text(isNew ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}

/// HOME SCREEN
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PetService _petService = PetService();
  late final _LifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    // Listen for app lifecycle changes to warn about unsaved data to prevent data loss if the user exits while an upload is active.
    _lifecycleObserver = _LifecycleObserver(onPause: _handleAppPause);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  void _handleAppPause() {
    final state = context.read<PetState>();
    if (state.hasUnsavedChanges || state.hasPending) {
      debugPrint(
          'Warning: Operations pending: ${state._pendingOperations.length}');
    }
  }

  void _showPetForm([Pet? pet, String? docId]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PetFormDialog(
        pet: pet,
        onSubmit: (data) async {
          final state = context.read<PetState>();
          final opId = DateTime.now().millisecondsSinceEpoch.toString();
          state.startOperation(opId);

          try {
            await _petService.savePet(data, docId: docId);
            if (!context.mounted) return;
//This prevents deactivated widgets ancestor errors if user navigated away while the database was processing.
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    docId == null ? 'Pet added successfully!' : 'Changes saved!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saving: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () => _showPetForm(pet, docId),
                ),
              ),
            );
          } finally {
            state.endOperation(opId);
          }
        },
      ),
    );
  }

  Future<void> _deletePet(BuildContext context, String docId, String name) async {
    final state = context.read<PetState>();
    final opId = DateTime.now().millisecondsSinceEpoch.toString();
    state.startOperation(opId);

    try {
      await _petService.deletePet(docId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted $name')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting $name: ${e.toString()}')),
      );
    } finally {
      state.endOperation(opId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PetState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tail Home'),
        actions: [
          if (state.hasPending)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _petService.streamPets(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No pets yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap the + button to add your first pet'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final pet = Pet.fromFirestore(doc);
              //Keeps the UI logic clean and prevents data field typos from crashing the ListView.
              //Fallback logic for pets with incomplete data in Firestore
              final name = pet.name.isNotEmpty ? pet.name : 'Unnamed';
              final breed = pet.breed.isNotEmpty ? pet.breed : 'Unknown breed';
              final age = pet.age > 0 ? '${pet.age} yrs' : 'Age unknown';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  key: ValueKey(doc.id),
                  leading: CircleAvatar(child: Text(name[0].toUpperCase())),
                  title:
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$breed • $age'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showPetForm(pet, doc.id);
                      } else if (value == 'delete') {
                        _deletePet(context, doc.id, name);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPetForm(),
        tooltip: 'Add Pet',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// HEALTH TRACKER SCREEN
class HealthTrackerScreen extends StatelessWidget {
  const HealthTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Health Tracker')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Vaccination logs will appear here.'),
            ],
          ),
        ),
      );
}

/// PET PROFILE SCREEN
class PetProfileScreen extends StatelessWidget {
  const PetProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pet Profiles')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Add your first pet!'),
            ],
          ),
        ),
      );
}

/// MAIN NAVIGATION SCREEN
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Pages displayed in IndexedStack for state preservation
  static const List<Widget> _pages = [
    HomeScreen(),
    HealthTrackerScreen(),
    PetProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //This preserves scroll positions and state when switching tabs so the user doesn't lose their place.
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.health_and_safety_rounded),
            label: 'Health',
          ),
          NavigationDestination(icon: Icon(Icons.pets_rounded), label: 'Pets'),
        ],
      ),
    );
  }
}
