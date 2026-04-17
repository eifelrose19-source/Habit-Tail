import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:habit_tail/theme/app_theme.dart';
import 'package:habit_tail/services/auth_service.dart';
import '../../models/task_model.dart'; 
import '../../providers/task_provider.dart'; 

class TasksDashboardScreen extends ConsumerStatefulWidget {
  const TasksDashboardScreen({super.key});

  @override
  ConsumerState<TasksDashboardScreen> createState() => _TasksDashboardScreenState();
}

class _TasksDashboardScreenState extends ConsumerState<TasksDashboardScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();
  
  String? _selectedPetId;
  String? _selectedChildId;
  String _selectedFrequency = 'Daily';
  String _sortBy = 'title'; 
  String? _familyId;
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final tokenResult = await user.getIdTokenResult();
      if (mounted) {
        final fId = tokenResult.claims?['family_id'] as String?;
        setState(() {
          _displayName = user.displayName;
          _familyId = fId;
        });
        if (fId != null) {
          ref.read(taskProvider.notifier).watchFamilyTasks(fId);
        }
      }
    }
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);
    
    final sortedTasks = [...tasks]..sort((a, b) {
       if (_sortBy == 'title') return a.title.compareTo(b.title);
       return 0;
    });

    return Scaffold(
      backgroundColor: AppTheme.beigeBackground,
      body: Column(
        children: [
          _buildHeader(_displayName ?? 'Parent'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildCreateTaskSection(_familyId),
                  const SizedBox(height: 10),
                  ...sortedTasks.where((t) => t.status == 'active').map((task) => _buildTaskCard(task)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Helpers (simplified for clarity)
  Widget _buildHeader(String name) => Text("Welcome $name");

  Widget _buildCreateTaskSection(String? familyId) {
    return Column(
      children: [
        _buildInputField('Task Title', _taskTitleController),
        _buildFirestoreDropdown(
          hint: 'Assign to Child',
          collection: 'users',
          familyId: familyId,
          value: _selectedChildId,
          onChanged: (val) => setState(() => _selectedChildId = val),
        ),
        ElevatedButton(
          onPressed: () => _handleAddTask(familyId),
          child: const Text("Add Task"),
        ),
      ],
    );
  }

  Future<void> _handleAddTask(String? familyId) async {
    if (familyId == null) return;
    final task = TaskModel(
      taskId: '',
      assignedTo: _selectedChildId ?? '',
      createdBy: '',
      familyId: familyId,
      frequency: _selectedFrequency,
      points: int.tryParse(_rewardController.text) ?? 0,
      title: _taskTitleController.text,
      status: 'active',
    );
    await ref.read(taskProvider.notifier).addTask(task);
  }

  Widget _buildTaskCard(TaskModel task) => ListTile(title: Text(task.title));

  Widget _buildFirestoreDropdown({
    required String hint,
    required String collection,
    required String? familyId,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    if (familyId == null) return const SizedBox.shrink();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where('family_id', isEqualTo: familyId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final items = snapshot.data!.docs.map((doc) {
          final data = doc.data();
          final name = data['display_name'] ?? data['name'] ?? 'Unknown';
          return DropdownMenuItem<String>(value: name, child: Text(name));
        }).toList();
        return DropdownButton<String>(value: value, items: items, onChanged: onChanged, hint: Text(hint));
      },
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) => TextField(controller: controller);
}