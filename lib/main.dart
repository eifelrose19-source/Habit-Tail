import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

// --- Screen Imports (uncomment as you build each screen) ---
// import 'screens/auth/splash_screen.dart';
// import 'screens/auth/login_screen.dart';
// import 'screens/auth/signup_screen.dart';
// import 'screens/onboarding/create_or_join_screen.dart';
// import 'screens/onboarding/who_are_you_screen.dart';
// import 'screens/parent/parent_dashboard.dart';
// import 'screens/child/child_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(
    const ProviderScope(
      child: HabitTailApp(),
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
        // Seed color only — specific colors come from AppTheme directly
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.softIris,
          primary: AppTheme.softIris,
          secondary: AppTheme.electricSky,
          onPrimary: AppTheme.midnightPlum,
          onSecondary: AppTheme.midnightPlum,
          onSurface: AppTheme.midnightPlum,
        ),
        // Google Fonts handles the font — no fontFamily string needed
        textTheme: GoogleFonts.quicksandTextTheme(),
        // Button and input styles come from AppTheme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.elevatedButtonStyle,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const _RootRouter(),
    );
  }
}

/// Watches auth and user state and routes accordingly.
/// Uncomment each screen as it gets built.
class _RootRouter extends ConsumerWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = ref.watch(userProvider);

    // Auth still initialising on cold start
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
      // Replace with: return const SplashScreen();
    }

    // Not logged in
    if (!auth.isAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Login Screen Coming Soon')),
      );
      // Replace with: return const LoginScreen();
    }

    // Logged in but Firestore doc still loading
    if (user.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
      // Replace with: return const SplashScreen();
    }

    // Logged in but no family set up yet
    if (user.needsFamilySetup) {
      return const Scaffold(
        body: Center(child: Text('Create or Join Screen Coming Soon')),
      );
      // Replace with: return const CreateOrJoinScreen();
    }

    // Has family but hasn't claimed a slot yet
    if (!user.isClaimed) {
      return const Scaffold(
        body: Center(child: Text('Who Are You Screen Coming Soon')),
      );
      // Replace with: return const WhoAreYouScreen();
    }

    // Fully onboarded — route by role
    if (user.isParent) {
      return const Scaffold(
        body: Center(child: Text('Parent Dashboard Coming Soon')),
      );
      // Replace with: return const ParentDashboard();
    }

    return const Scaffold(
      body: Center(child: Text('Child Dashboard Coming Soon')),
    );
    // Replace with: return const ChildDashboard();
  }
}