import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tail/theme/app_theme.dart';
import 'package:habit_tail/services/auth_service.dart';

class TasksDashboardScreen extends StatefulWidget {
  const TasksDashboardScreen({super.key});

  @override
  State<TasksDashboardScreen> createState() => _TasksDashboardScreenState();
}

class _TasksDashboardScreenState extends State<TasksDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
        setState(() {
          _displayName = user.displayName;
          _familyId = tokenResult.claims?['family_id'] as String?;
        });
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
                  const SizedBox(height: 15),
                  _buildSortButton(),
                  const SizedBox(height: 10),
                  _buildTasksStream(_familyId),
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

  Widget _buildTasksStream(String? familyId) {
    if (familyId == null) return const Center(child: CircularProgressIndicator());

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('tasks')
          .where('family_id', isEqualTo: familyId)
          .where('status', isEqualTo: 'active')
          .orderBy(_sortBy)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return _buildTaskCard(data);
          }).toList(),
        );
      },
    );
  }

  Widget _buildHeader(String name) {
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
              Text('$name!', style: AppTheme.bodyText(fontSize: 24, fontWeight: FontWeight.bold)),
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

  Widget _buildCreateTaskSection(String? familyId) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.electricSky.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Create Task', style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          _buildInputField('Task Title', _taskTitleController),
          const SizedBox(height: 8),
          _buildFirestoreDropdown(
            hint: 'Assigned Pet',
            collection: 'pets',
            familyId: familyId,
            value: _selectedPetId,
            onChanged: (val) => setState(() => _selectedPetId = val),
          ),
          const SizedBox(height: 8),
          _buildFirestoreDropdown(
            hint: 'Assigned To',
            collection: 'users',
            familyId: familyId,
            isChildFilter: true,
            value: _selectedChildId,
            onChanged: (val) => setState(() => _selectedChildId = val),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildRewardField(_rewardController),
              const SizedBox(width: 10),
              _buildFrequencyPicker(
                current: _selectedFrequency,
                onSelect: (val) => setState(() => _selectedFrequency = val),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _addTaskToFirestore(familyId),
                style: AppTheme.elevatedButtonStyle,
                child: Text('Add Task', style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFirestoreDropdown({
    required String hint,
    required String collection,
    required String? familyId,
    required String? value,
    required ValueChanged<String?> onChanged,
    bool isChildFilter = false,
  }) {
    if (familyId == null) return const SizedBox.shrink();

    Query query = _firestore.collection(collection).where('family_id', isEqualTo: familyId);
    if (isChildFilter) query = query.where('role', isEqualTo: 'child');

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        List<DropdownMenuItem<String>> items = [];
        if (snapshot.hasData) {
          items = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String name = data['display_name'] ?? data['name'] ?? 'Unknown';
            return DropdownMenuItem<String>(
              value: name,
              child: Text(name, style: AppTheme.bodyText(fontSize: 13)),
            );
          }).toList();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(hint, style: AppTheme.bodyText(fontSize: 13)),
              value: value,
              items: items,
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }

  Future<void> _addTaskToFirestore(String? familyId) async {
    if (familyId == null || _taskTitleController.text.isEmpty) return;

    await _firestore.collection('tasks').add({
      'title': _taskTitleController.text,
      'pet': _selectedPetId,
      'assignedTo': _selectedChildId,
      'gold': int.tryParse(_rewardController.text) ?? 0,
      'frequency': _selectedFrequency,
      'family_id': familyId,
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
    });

    _taskTitleController.clear();
    _rewardController.clear();
    if (mounted) {
      setState(() {
        _selectedPetId = null;
        _selectedChildId = null;
        _selectedFrequency = 'Daily';
      });
    }
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
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
                Text('Task: ${task['title']}', style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('Pet: ${task['pet'] ?? 'None'}', style: AppTheme.bodyText(fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assigned to:', style: AppTheme.bodyText(fontSize: 11)),
                Text(task['assignedTo'] ?? 'Unassigned', style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Due: ${task['frequency']}', style: AppTheme.bodyText(fontSize: 11)),
                Text('Gold: ${task['gold']}', style: AppTheme.bodyText(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showEditTaskModal(task),
            style: AppTheme.elevatedButtonStyle.copyWith(
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
            ),
            child: Text('Update/Edit', style: AppTheme.bodyText(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditTaskModal(Map<String, dynamic> task) {
    final titleEditController = TextEditingController(text: task['title']);
    final rewardEditController = TextEditingController(text: task['gold'].toString());
    String? pet = task['pet'];
    String? assigned = task['assignedTo'];
    String freq = task['frequency'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) => StatefulBuilder(
        builder: (stContext, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 25, right: 25, top: 25,
            bottom: MediaQuery.of(stContext).viewInsets.bottom + 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Update / Edit Task', style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildInputField('Task Title', titleEditController),
              const SizedBox(height: 8),
              _buildFirestoreDropdown(
                hint: 'Assigned Pet',
                collection: 'pets',
                familyId: task['family_id'],
                value: pet,
                onChanged: (val) => setModalState(() => pet = val),
              ),
              const SizedBox(height: 8),
              _buildFirestoreDropdown(
                hint: 'Assigned To',
                collection: 'users',
                familyId: task['family_id'],
                isChildFilter: true,
                value: assigned,
                onChanged: (val) => setModalState(() => assigned = val),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildRewardField(rewardEditController),
                  const SizedBox(width: 10),
                  _buildFrequencyPicker(
                    current: freq,
                    onSelect: (val) => setModalState(() => freq = val),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              AppTheme.buildButton(
                context: modalContext,
                label: 'Save Changes',
                onTap: () async {
                  await _firestore.collection('tasks').doc(task['id']).update({
                    'title': titleEditController.text,
                    'pet': pet,
                    'assignedTo': assigned,
                    'gold': int.tryParse(rewardEditController.text) ?? 0,
                    'frequency': freq,
                  });
                  // Fix: Check context.mounted for the specific context being used
                  if (!modalContext.mounted) return;
                  Navigator.pop(modalContext);
                },
              ),
              const SizedBox(height: 10),
              AppTheme.buildButton(
                context: modalContext,
                label: 'Delete Task',
                onTap: () async {
                  await _firestore.collection('tasks').doc(task['id']).delete();
                  // Fix: Check context.mounted for the specific context being used
                  if (!modalContext.mounted) return;
                  Navigator.pop(modalContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sort Tasks', style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...{'title': 'Name', 'assignedTo': 'Child', 'pet': 'Pet'}.entries.map((entry) => ListTile(
              leading: Icon(
                _sortBy == entry.key ? Icons.radio_button_checked : Icons.radio_button_off,
                color: AppTheme.midnightPlum,
              ),
              title: Text('Sort by ${entry.value}', style: AppTheme.bodyText(fontSize: 14)),
              onTap: () {
                setState(() => _sortBy = entry.key);
                Navigator.pop(modalContext);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.bodyText(fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      style: AppTheme.bodyText(fontSize: 13),
    );
  }

  Widget _buildRewardField(TextEditingController controller) {
    return SizedBox(
      width: 80,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Gold',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        style: AppTheme.bodyText(fontSize: 13),
      ),
    );
  }

  Widget _buildFrequencyPicker({required String current, required ValueChanged<String> onSelect}) {
    return Expanded(
      child: Row(
        children: ['Daily', 'Weekly', 'Monthly'].map((freq) {
          final bool isSelected = current == freq;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(freq),
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.softIris : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(freq, style: AppTheme.bodyText(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () => _showSortModal(),
        style: AppTheme.elevatedButtonStyle,
        icon: const Icon(Icons.sort, size: 16),
        label: Text('Sort', style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
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