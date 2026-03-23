import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/family_provider.dart';
import 'providers/task_provider.dart';
import 'providers/pet_provider.dart';
import 'providers/reward_provider.dart';
import 'providers/redemption_log_provider.dart';
import 'theme/app_colors.dart';

// Authenticated Screen Imports
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/create_or_join_family_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore offline persistence with unlimited cache size
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
        ChangeNotifierProvider(create: (_) => RedemptionLogProvider()),
      ],
      child: const HabitTailApp(),
    ),
  );
}

class HabitTailApp extends StatelessWidget {
  const HabitTailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitTail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.softIris,
          primary: AppColors.softIris,
          secondary: AppColors.blushPink,
          tertiary: AppColors.electricSky,
          surface: AppColors.pureWhite,
          onPrimary: AppColors.midnightPlum,
          onSecondary: AppColors.midnightPlum,
          onSurface: AppColors.midnightPlum,
        ),
        fontFamily: 'Quicksand',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.midnightPlum,
          ), // H1 (Hero)
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.midnightPlum,
          ), // H2 (Screen)
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.midnightPlum,
          ), // Body (Main)
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.midnightPlum,
          ), // Button
          bodySmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.midnightPlum,
          ), // Caption
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.pureWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/create-or-join-family': (context) => const CreateOrJoinFamilyScreen(),
        '/home': (context) => const MainNavigationScreen(),
      },
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

  // Temporary Placeholders until you finish the Dashboard/Task screens
  final List<Widget> _pages = [
    const Center(child: Text('Home Dashboard Coming Soon')),
    const Center(child: Text('Tasks Screen')),
    const Center(child: Text('Rewards Screen')),
    const Center(child: Text('Pets Screen')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        indicatorColor: AppColors.softIris.withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.task_alt_rounded), label: 'Tasks'),
          NavigationDestination(
              icon: Icon(Icons.card_giftcard_rounded), label: 'Rewards'),
          NavigationDestination(
              icon: Icon(Icons.pets_rounded), label: 'Pets'),
        ],
      ),
    );
  }
}
