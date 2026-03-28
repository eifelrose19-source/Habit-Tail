import 'package:flutter/material.dart';
import 'package:habit_tail/theme/app_theme.dart';

class TasksDashboardScreen extends StatefulWidget {
  const TasksDashboardScreen({super.key});

  @override
  State<TasksDashboardScreen> createState() => _TasksDashboardScreenState();
}

class _TasksDashboardScreenState extends State<TasksDashboardScreen> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _assignedPetController = TextEditingController();
  final TextEditingController _assignedToController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();
  String _selectedFrequency = 'Daily';

  // TODO: Replace hardcoded tasks with real data from Firestore
  // Query tasks collection where family_id matches, ordered by current sort
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Feed Pet', 'pet': 'Fido', 'assignedTo': 'Tommy', 'frequency': 'Daily', 'gold': 100},
    {'title': 'Feed Pet', 'pet': 'Fido', 'assignedTo': 'Tommy', 'frequency': 'Daily', 'gold': 100},
    {'title': 'Feed Pet', 'pet': 'Fido', 'assignedTo': 'Tommy', 'frequency': 'Daily', 'gold': 100},
    {'title': 'Feed Pet', 'pet': 'Fido', 'assignedTo': 'Tommy', 'frequency': 'Daily', 'gold': 100},
    {'title': 'Feed Pet', 'pet': 'Fido', 'assignedTo': 'Tommy', 'frequency': 'Daily', 'gold': 100},
    {'title': 'Feed Pet', 'pet': 'Fido', 'assignedTo': 'Tommy', 'frequency': 'Daily', 'gold': 100},
  ];

  String _sortBy = 'Date';

  @override
  void dispose() {
    _taskTitleController.dispose();
    _assignedPetController.dispose();
    _assignedToController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildCreateTaskSection(),
                  const SizedBox(height: 15),
                  _buildSortButton(),
                  const SizedBox(height: 10),
                  ..._tasks.map((task) => _buildTaskCard(task)),
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

  Widget _buildCreateTaskSection() {
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
            child: Text('Create Task',
                style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          _buildInputField('Task Title', _taskTitleController),
          const SizedBox(height: 8),
          // TODO: Replace with dropdown populated from Firestore pets collection
          _buildInputField('Assigned Pet', _assignedPetController),
          const SizedBox(height: 8),
          // TODO: Replace with dropdown populated from Firestore family members
          _buildInputField('Assigned To', _assignedToController),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reward:', style: AppTheme.bodyText(fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _rewardController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: AppTheme.bodyText(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Frequency:', style: AppTheme.bodyText(fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: ['Daily', 'Weekly', 'Monthly'].map((freq) {
                        final bool isSelected = _selectedFrequency == freq;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFrequency = freq),
                            child: Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.softIris : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(freq,
                                  style: AppTheme.bodyText(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Add task to Firestore
                    // - Create task document with title, pet, assignedTo, reward, frequency, family_id, status: active
                    // - Clear form fields after adding
                  },
                  style: AppTheme.elevatedButtonStyle,
                  child: Text('Add Task', style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      style: AppTheme.bodyText(fontSize: 13),
    );
  }

  Widget _buildSortButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () => _showSortModal(),
        style: AppTheme.elevatedButtonStyle,
        icon: const Icon(Icons.sort, size: 16),
        label: Text('Sort by: $_sortBy', style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
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
                Text('Task: ${task['title']}',
                    style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('Pet: ${task['pet']}', style: AppTheme.bodyText(fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assigned to:', style: AppTheme.bodyText(fontSize: 11)),
                Text(task['assignedTo'],
                    style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Due: ${task['frequency']}', style: AppTheme.bodyText(fontSize: 11)),
                Text('Gold: ${task['gold']}',
                    style: AppTheme.bodyText(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showEditTaskModal(task),
            style: AppTheme.elevatedButtonStyle.copyWith(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
            ),
            child: Text('Update/Edit',
                style: AppTheme.bodyText(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sort Tasks',
                style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...['Date', 'Child', 'Pet'].map((option) => ListTile(
                  leading: Icon(
                    _sortBy == option ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: AppTheme.midnightPlum,
                  ),
                  title: Text('Sort by $option', style: AppTheme.bodyText(fontSize: 14)),
                  onTap: () {
                    setState(() => _sortBy = option);
                    // TODO: Re-query Firestore with new sort order
                    Navigator.pop(modalContext);
                  },
                )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showEditTaskModal(Map<String, dynamic> task) {
    final TextEditingController titleController =
        TextEditingController(text: task['title']);
    final TextEditingController petController =
        TextEditingController(text: task['pet']);
    final TextEditingController assignedToController =
        TextEditingController(text: task['assignedTo']);
    final TextEditingController rewardController =
        TextEditingController(text: task['gold'].toString());
    String selectedFrequency = task['frequency'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 25,
            right: 25,
            top: 25,
            bottom: MediaQuery.of(context).viewInsets.bottom + 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Update / Edit Task',
                  style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildInputField('Task Title', titleController),
              const SizedBox(height: 8),
              // TODO: Replace with dropdown populated from Firestore pets collection
              _buildInputField('Assigned Pet', petController),
              const SizedBox(height: 8),
              // TODO: Replace with dropdown populated from Firestore family members
              _buildInputField('Assigned To', assignedToController),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: rewardController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Gold',
                        hintStyle: AppTheme.bodyText(fontSize: 13),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: AppTheme.bodyText(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: ['Daily', 'Weekly', 'Monthly'].map((freq) {
                        final bool isSelected = selectedFrequency == freq;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => selectedFrequency = freq),
                            child: Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.softIris : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(freq,
                                  style: AppTheme.bodyText(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              AppTheme.buildButton(
                context: modalContext,
                label: 'Save Changes',
                onTap: () {
                  // TODO: Update task document in Firestore with new values
                  Navigator.pop(modalContext);
                },
              ),
              const SizedBox(height: 10),
              AppTheme.buildButton(
                context: modalContext,
                label: 'Delete Task',
                onTap: () {
                  // TODO: Delete task document from Firestore
                  // - Remove task ID from any child's assigned tasks
                  Navigator.pop(modalContext);
                },
              ),
            ],
          ),
        ),
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