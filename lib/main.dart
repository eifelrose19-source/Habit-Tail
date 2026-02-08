import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

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

  runApp(
    const ProviderScope(
      child: HabitTailApp(),
    ),
  );
}

class HabitTailApp extends StatelessWidget {
  const HabitTailApp({super.key});

  // --- HabitTail Color Palette ---
  static const Color softIris = Color(0xFFD0BFFF);      // Primary
  static const Color blushPink = Color(0xFFFFADBC);     // Secondary
  static const Color electricSky = Color(0xFF98E4FF);   // Accent
  static const Color pureWhite = Color(0xFFFFFFFF);     // Surface
  static const Color midnightPlum = Color(0xFF3F2E5A);  // Deep Text

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitTail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: softIris,
          primary: softIris,
          secondary: blushPink,
          tertiary: electricSky,
          surface: pureWhite,
          onPrimary: midnightPlum,
          onSecondary: midnightPlum,
          onSurface: midnightPlum,
        ),
        fontFamily: 'Quicksand',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: midnightPlum,
          ), // H1 (Hero)
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: midnightPlum,
          ), // H2 (Screen)
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: midnightPlum,
          ), // Body (Main)
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: midnightPlum,
          ), // Button
          bodySmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: midnightPlum,
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
          fillColor: pureWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        indicatorColor: const Color(0xFFD0BFFF).withValues(alpha: 0.3), 
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.task_alt_rounded), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.card_giftcard_rounded), label: 'Rewards'),
          NavigationDestination(icon: Icon(Icons.pets_rounded), label: 'Pets'),
        ],
      ),
    );
  }
}