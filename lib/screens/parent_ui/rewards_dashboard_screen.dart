import 'package:flutter/material.dart';
import 'package:habit_tail/theme/app_theme.dart';

class RewardsDashboardScreen extends StatefulWidget {
  const RewardsDashboardScreen({super.key});

  @override
  State<RewardsDashboardScreen> createState() => _RewardsDashboardScreenState();
}

class _RewardsDashboardScreenState extends State<RewardsDashboardScreen> {
  final TextEditingController _rewardTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  // TODO: Replace hardcoded rewards with real data from Firestore
  // Query rewards collection where family_id matches, ordered by current sort
  final List<Map<String, dynamic>> _rewards = [
    {'title': '30 Mins Game Time', 'description': 'Unlock 30mins of video game for the day', 'cost': 200, 'status': 'Claimed'},
    {'title': '30 Mins Game Time', 'description': 'Unlock 30mins of video game for the day', 'cost': 200, 'status': 'Claimed'},
    {'title': '30 Mins Game Time', 'description': 'Unlock 30mins of video game for the day', 'cost': 200, 'status': 'Claimed'},
    {'title': '30 Mins Game Time', 'description': 'Unlock 30mins of video game for the day', 'cost': 200, 'status': 'Claimed'},
    {'title': '30 Mins Game Time', 'description': 'Unlock 30mins of video game for the day', 'cost': 200, 'status': 'Unclaimed'},
    {'title': '30 Mins Game Time', 'description': 'Unlock 30mins of video game for the day', 'cost': 200, 'status': 'Unclaimed'},
  ];

  String _sortBy = 'Status';

  @override
  void dispose() {
    _rewardTitleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
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
                  _buildCreateRewardSection(),
                  const SizedBox(height: 15),
                  _buildSortButton(),
                  const SizedBox(height: 10),
                  ..._rewards.map((reward) => _buildRewardCard(reward)),
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

  Widget _buildCreateRewardSection() {
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
            child: Text('Create Reward',
                style: AppTheme.bodyText(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          _buildInputField('Reward Title', _rewardTitleController),
          const SizedBox(height: 8),
          _buildInputField('Description', _descriptionController, maxLines: 2),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cost:', style: AppTheme.bodyText(fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _costController,
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
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Add reward to Firestore
                    // - Create reward document with title, description, cost, family_id, status: Unclaimed
                    // - Clear form fields after adding
                  },
                  style: AppTheme.elevatedButtonStyle,
                  child: Text('Add Reward',
                      style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
        label: Text('Sort by: $_sortBy',
            style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward) {
    final bool isClaimed = reward['status'] == 'Claimed';
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
                Text('Reward: ${reward['title']}',
                    style: AppTheme.bodyText(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('Cost: ${reward['cost']}', style: AppTheme.bodyText(fontSize: 11)),
                Text(
                  'Status: ${reward['status']}',
                  style: AppTheme.bodyText(fontSize: 11).copyWith(
                    color: isClaimed ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              if (isClaimed)
                ElevatedButton(
                  onPressed: () {
                    // TODO: Update reward status to Unclaimed in Firestore
                    setState(() => reward['status'] = 'Unclaimed');
                  },
                  style: AppTheme.elevatedButtonStyle.copyWith(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                  child: Text('Renew',
                      style: AppTheme.bodyText(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ElevatedButton(
                onPressed: () => _showEditRewardModal(reward),
                style: AppTheme.elevatedButtonStyle.copyWith(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                child: Text('Edit',
                    style: AppTheme.bodyText(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
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
            Text('Sort Rewards',
                style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...['Status', 'Claimed', 'Unclaimed'].map((option) => ListTile(
                  leading: Icon(
                    _sortBy == option
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: AppTheme.midnightPlum,
                  ),
                  title: Text('Show $option', style: AppTheme.bodyText(fontSize: 14)),
                  onTap: () {
                    setState(() => _sortBy = option);
                    // TODO: Re-query Firestore filtering by status
                    Navigator.pop(modalContext);
                  },
                )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showEditRewardModal(Map<String, dynamic> reward) {
    final TextEditingController titleController =
        TextEditingController(text: reward['title']);
    final TextEditingController descController =
        TextEditingController(text: reward['description']);
    final TextEditingController costController =
        TextEditingController(text: reward['cost'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.only(
          left: 25,
          right: 25,
          top: 25,
          bottom: MediaQuery.of(context).viewInsets.bottom + 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Reward',
                style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildInputField('Reward Title', titleController),
            const SizedBox(height: 8),
            _buildInputField('Description', descController, maxLines: 2),
            const SizedBox(height: 8),
            _buildInputField('Cost', costController),
            const SizedBox(height: 15),
            AppTheme.buildButton(
              context: modalContext,
              label: 'Save Changes',
              onTap: () {
                // TODO: Update reward document in Firestore with new values
                Navigator.pop(modalContext);
              },
            ),
            const SizedBox(height: 10),
            AppTheme.buildButton(
              context: modalContext,
              label: 'Delete Reward',
              onTap: () {
                // TODO: Delete reward document from Firestore
                Navigator.pop(modalContext);
              },
            ),
            const SizedBox(height: 10),
          ],
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