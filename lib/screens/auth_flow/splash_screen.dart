import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../main.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => RootRouter()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // Logo
              Image.asset(
                'assets/images/icons/hbtletters.png',
                width: screenWidth * 0.65,
                fit: BoxFit.contain,
              ),

              const Spacer(flex: 1),

              // Animals
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/icons/hbtdog.png',
                    width: screenWidth * 0.35,
                    fit: BoxFit.contain,
                  ),
                  Image.asset(
                    'assets/images/icons/hbthamster.png',
                    width: screenWidth * 0.30,
                    fit: BoxFit.contain,
                  ),
                  Image.asset(
                    'assets/images/icons/hbtkitty.png',
                    width: screenWidth * 0.35,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}