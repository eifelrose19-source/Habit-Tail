import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/family_provider.dart';
import '../../providers/auth_provider.dart';
import 'create_family_code_screen.dart';

class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  String get _pin =>
      _controllers.map((c) => c.text).join();

  bool get _pinComplete => _pin.length == 4;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  void _copyPin() {
    if (!_pinComplete) return;
    Clipboard.setData(ClipboardData(text: _pin));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PIN copied to clipboard',
            style: AppTheme.caption(color: AppTheme.surface)),
        backgroundColor: AppTheme.statusCompleted,
      ),
    );
  }

  Future<void> _savePin() async {
    if (!_pinComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a 4-digit PIN',
              style: AppTheme.caption(color: AppTheme.surface)),
          backgroundColor: AppTheme.statusRejected,
        ),
      );
      return;
    }

    final uid = ref.read(authProvider).userId;
    if (uid == null) return;

    // Save PIN to Firestore via familyProvider
    await ref.read(familyProvider.notifier).savePinForUser(uid, _pin);

    final error = ref.read(familyProvider).error;
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error,
              style: AppTheme.caption(color: AppTheme.surface)),
          backgroundColor: AppTheme.statusRejected,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CreateFamilyCodeScreen(parentalPin: _pin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final familyState = ref.watch(familyProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spacingXXL),

                // Title
                Text('Create Parental Pin...', style: AppTheme.h2()),

                const Spacer(flex: 2),

                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/icons/hbtletters.png',
                    width: screenWidth * 0.65,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXXL),

                // Instruction
                Center(
                  child: Text(
                    'Set your 4 digit Parental Pin:',
                    style: AppTheme.body(),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingL),

                // 4 PIN boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 56,
                      height: 56,
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingS),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: _focusNodes[index].hasFocus
                              ? AppTheme.electricSky
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        obscureText: true,
                        style: AppTheme.h2(),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onDigitEntered(index, value),
                        onKeyboardAppearanceBrightness: null,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: AppTheme.spacingXXL),

                // Copy Code + Create Pin buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _copyPin,
                        style: AppTheme.outlineButtonStyle,
                        child: Text('Copy Code',
                            style: AppTheme.buttonText()),
                      ),
                    ),
                    const SizedBox(width: AppTheme.itemGap),
                    Expanded(
                      child: familyState.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.electricSky),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _savePin,
                              style: AppTheme.elevatedButtonStyle,
                              child: Text('Create Pin',
                                  style: AppTheme.buttonText()),
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Warning text
                Center(
                  child: Text(
                    'Parents only — do not share with children.',
                    textAlign: TextAlign.center,
                    style: AppTheme.caption(
                        color: AppTheme.midnightPlum.withAlpha(180)),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}