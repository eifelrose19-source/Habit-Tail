import 'package:flutter/material.dart';
import 'package:habit_tail/theme/app_theme.dart';
import 'package:habit_tail/screens/auth/who_are_you_screen.dart';

class ManageFamilyScreen extends StatefulWidget {
  const ManageFamilyScreen({super.key});

  @override
  State<ManageFamilyScreen> createState() => _ManageFamilyScreenState();
}

class _ManageFamilyScreenState extends State<ManageFamilyScreen> {
  final TextEditingController _partnerController = TextEditingController();
  final TextEditingController _child1Controller = TextEditingController();
  final TextEditingController _child2Controller = TextEditingController();
  final TextEditingController _child3Controller = TextEditingController();

  @override
  void dispose() {
    _partnerController.dispose();
    _child1Controller.dispose();
    _child2Controller.dispose();
    _child3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme.screenWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          Text(
            'Create your family here. Enter your family names below:',
            textAlign: TextAlign.center,
            style: AppTheme.bodyText(),
          ),

          const SizedBox(height: 24),

          _buildTextField('Partner Name', _partnerController),
          const SizedBox(height: 16),
          _buildTextField('Child 1', _child1Controller),
          const SizedBox(height: 16),
          _buildTextField('Child 2', _child2Controller),
          const SizedBox(height: 16),
          _buildTextField('Child 3', _child3Controller),

          const SizedBox(height: 32),

          Image.asset('assets/images/icons/hbtletters.png', width: 250, fit: BoxFit.contain),

          const Spacer(flex: 3),

          AppTheme.buildButton(
            context: context,
            label: "Add Family",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WhoAreYouScreen(
                    partnerName: _partnerController.text.isEmpty ? 'Partner' : _partnerController.text,
                    child1Name: _child1Controller.text.isEmpty ? 'Child 1' : _child1Controller.text,
                    child2Name: _child2Controller.text.isEmpty ? 'Child 2' : _child2Controller.text,
                    child3Name: _child3Controller.text.isEmpty ? 'Child 3' : _child3Controller.text,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: AppTheme.codeBoxDecoration(),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.bodyText(fontSize: 18, fontWeight: FontWeight.w600).copyWith(
            color: AppTheme.midnightPlum.withAlpha(128),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}