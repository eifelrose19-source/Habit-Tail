import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to LoginScreen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // App Logo / Text Image
              Image.asset(
                'assets/images/icons/hbtletters.png',
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
              ),
              
              const SizedBox(height: AppTheme.spacingL),

              // Pet Group Image
              Image.asset(
                'assets/images/icons/hbtapp_icon.png',
                width: MediaQuery.of(context).size.width * 0.8,
                fit: BoxFit.contain,
              ),

              const Spacer(flex: 1),
              
              // Loading Indicator (Optional, for polish)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.electricSky),
              ),
              
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}