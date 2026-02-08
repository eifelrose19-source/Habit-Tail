import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/family_service.dart';
import '../../models/family_model.dart';

class CreateFamilyScreen extends StatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  State<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends State<CreateFamilyScreen> {
  final _formKey = GlobalKey<FormState>();

  String _subscriptionLevel = 'free';
  bool _isLoading = false;

  Future<void> _handleCreateFamily() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId!;

      final familyId = 'Fam_${DateTime.now().millisecondsSinceEpoch}';

      final family = FamilyModel(
        familyId: familyId,
        adminUid: userId,
        createdAt: DateTime.now(),
        subscriptionLevel: _subscriptionLevel,
        memberIds: [userId],
      );

      final familyService = FamilyService();
      await familyService.createFamily(familyId, family);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Family created successfully!',
              style: TextStyle(fontFamily: 'Quicksand'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Quicksand'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSubscriptionOption(String title, String subtitle, String value) {
    bool isSelected = _subscriptionLevel == value;

    return InkWell(
      onTap: () {
        setState(() {
          _subscriptionLevel = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD0BFFF) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: const Color(0xFF3F2E5A),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF3F2E5A),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD0BFFF), Color(0xFFFFADBC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/icons/hbtdog.png',
                          width: 80,
                          height: 80,
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/images/icons/hbtkitty.png',
                          width: 80,
                          height: 80,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create your family',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F2E5A),
                      ),
                    ),
                    const SizedBox(height: 48),

                    _buildSubscriptionOption(
                        'Free', 'Basic features', 'free'),
                    const SizedBox(height: 12),
                    _buildSubscriptionOption(
                        'Premium', 'All features unlocked', 'premium'),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _handleCreateFamily,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF3F2E5A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Create Family',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
