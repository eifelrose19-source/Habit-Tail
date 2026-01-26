import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:habit_tail/models/pet_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enhanced offline persistence with caching
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    // -1 disables cache size limits (unlimited)
    cacheSizeBytes: -1,
  );

  runApp(const HabitTailApp());
}

class HabitTailApp extends StatelessWidget {
  const HabitTailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Use const widgets and lazy initialization for better performance
  static const List<Widget> _pages = [
    HomeScreen(),
    HealthTrackerScreen(),
    PetProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
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

// Optimized Home Screen with better error handling and performance
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference<Map<String, dynamic>> _pets = FirebaseFirestore
      .instance
      .collection('pets');

  // Track pending operations to prevent data loss
  final Set<String> _pendingOperations = {};
  bool _hasUnsavedChanges = false;
  late final _LifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    // Listen for app lifecycle changes to warn about unsaved data
    _lifecycleObserver = _LifecycleObserver(onPause: _handleAppPause);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  void _handleAppPause() {
    if (_hasUnsavedChanges || _pendingOperations.isNotEmpty) {
      // Show notification that saves are in progress
      debugPrint('Warning: Operations pending: ${_pendingOperations.length}');
    }
  }

  Future<void> _addOrEditPet(
    BuildContext context, [
    DocumentSnapshot<Map<String, dynamic>>? doc,
  ]) async {
    final data = doc?.data() ?? <String, dynamic>{};

    final nameController = TextEditingController(
      text: data['name']?.toString() ?? '',
    );
    final breedController = TextEditingController(
      text: data['breed']?.toString() ?? '',
    );
    final ageController = TextEditingController(
      text: data['age']?.toString() ?? '',
    );

    final isNew = doc == null;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (context) => AlertDialog(
        title: Text(isNew ? 'Add Pet' : 'Edit Pet'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final breed = breedController.text.trim();
              final age = int.tryParse(ageController.text.trim()) ?? 0;

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name is required')),
                );
                return;
              }

              Navigator.of(
                context,
              ).pop({'name': name, 'breed': breed, 'age': age});
            },
            child: Text(isNew ? 'Add' : 'Save'),
          ),
        ],
      ),
    );

    // Handle the save operation with proper error handling
    if (!context.mounted) return;
    if (result != null) {
      await _savePet(context, result, doc?.id, isNew);
    }

    // Clean up controllers
    nameController.dispose();
    breedController.dispose();
    ageController.dispose();
  }

  Future<void> _savePet(
    BuildContext context,
    Map<String, dynamic> data,
    String? docId,
    bool isNew,
  ) async {
    final operationId = DateTime.now().millisecondsSinceEpoch.toString();
    _pendingOperations.add(operationId);
    _hasUnsavedChanges = true;

    // Show loading indicator
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(isNew ? 'Adding pet...' : 'Saving changes...'),
          ],
        ),
        duration: const Duration(
          seconds: 30,
        ), // Long duration for slow connections
      ),
    );

    try {
      // Use WriteBatch for atomic operations and better performance
      final batch = FirebaseFirestore.instance.batch();

      if (isNew) {
        final newDoc = _pets.doc(); // Generate ID client-side
        batch.set(newDoc, {...data, 'createdAt': FieldValue.serverTimestamp()});
      } else {
        batch.update(_pets.doc(docId), {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Commit the batch - this will work offline and sync when online

      await batch.commit();

      if (!context.mounted) return;

      _pendingOperations.remove(operationId);
      _hasUnsavedChanges = _pendingOperations.isNotEmpty;

      // Dismiss loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNew ? 'Pet added successfully!' : 'Changes saved!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      _pendingOperations.remove(operationId);
      _hasUnsavedChanges = _pendingOperations.isNotEmpty;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show error with retry option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _savePet(context, data, docId, isNew),
          ),
        ),
      );
    }
  }

  Future<void> _deletePet(BuildContext context, String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed != true) return;

    final operationId = DateTime.now().millisecondsSinceEpoch.toString();
    _pendingOperations.add(operationId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Deleting pet...'),
          ],
        ),
      ),
    );

    try {
      await _pets.doc(id).delete();

      if (!context.mounted) return;

      _pendingOperations.remove(operationId);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name deleted'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _pendingOperations.remove(operationId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _deletePet(context, id, name),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tail Home'),
        actions: [
          if (_pendingOperations.isNotEmpty)
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
        stream: _pets.orderBy('name').snapshots(),
        builder: (context, snapshot) {
          // Enhanced error handling
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

          // Show cached data immediately while loading
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

          // Use ListView.builder with proper keys for better performance
          return ListView.builder(
            itemCount: docs.length,
            // Add padding for better UX
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final pet = Pet.fromFirestore(doc);
              final name = pet.name.isNotEmpty ? pet.name : 'Unnamed';
              final breed = pet.breed.isNotEmpty ? pet.breed : 'Unknown breed';
              final age = pet.age > 0 ? '${pet.age} yrs' : 'Age unknown';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  key: ValueKey(doc.id), // Add key for better performance
                  leading: CircleAvatar(child: Text(name[0].toUpperCase())),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$breed • $age'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _addOrEditPet(context, doc);
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
        onPressed: () => _addOrEditPet(context),
        tooltip: 'Add Pet',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Lifecycle observer to handle app state changes
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
