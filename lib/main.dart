import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/family_provider.dart';

// --- Screen Imports ---
import 'screens/auth_flow/splash_screen.dart';
import 'screens/auth_flow/login_screen.dart';
import 'screens/auth_flow/createorjoin_screen.dart';
import 'screens/auth_flow/who_are_you_screen.dart';
import 'screens/parent_ui/parent_dashboard_screen.dart';
import 'screens/child_ui/child_dashboard_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.softIris,
          primary: AppTheme.softIris,
          secondary: AppTheme.electricSky,
          onPrimary: AppTheme.midnightPlum,
          onSecondary: AppTheme.midnightPlum,
          onSurface: AppTheme.midnightPlum,
        ),
        textTheme: GoogleFonts.quicksandTextTheme(),
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
      home: const RootRouter(),
    );
  }
}

/// Single source of truth for navigation.
///
/// Flow:
///   Not authed          → SplashScreen (while loading) / LoginScreen
///   Authed, no family   → CreateOrJoinScreen
///     └─ Create family  → ManageFamilyScreen (family code + pin setup handled inside)
///     └─ Join family    → JoinFamilyScreen → WhoAreYouScreen
///   Authed, has family,
///     not yet claimed   → WhoAreYouScreen
///   Fully onboarded
///     parent            → ParentDashboardScreen
///     child             → ChildDashboardScreen
class RootRouter extends ConsumerWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = ref.watch(userProvider);

    // ── 1. Auth still initialising on cold start ──────────────────────────
    if (auth.isLoading) {
      return const SplashScreen();
    }

    // ── 2. Not logged in ──────────────────────────────────────────────────
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    // ── 3. Logged in but Firestore doc still loading ──────────────────────
    if (user.isLoading || user.user == null) {
      return const SplashScreen();
    }

    // ── 4. New user — no family yet → offer Create or Join ───────────────
    if (user.needsFamilySetup) {
      return const CreateOrJoinScreen();
    }

    // ── 5. Has a familyId but hasn't claimed a slot → WhoAreYou ──────────
    if (!user.isClaimed) {
      final familyId = user.user?.familyId ?? '';

      // Shouldn't happen, but guard against empty familyId
      if (familyId.isEmpty) return const CreateOrJoinScreen();

      final slotsAsync = ref.watch(availableSlotsProvider(familyId));

      return slotsAsync.when(
        loading: () => const SplashScreen(),
        error: (_, __) => const SplashScreen(),
        data: (slots) => WhoAreYouScreen(
          familyId: familyId,
          availableSlots: slots,
        ),
      );
    }

    // ── 6. Fully onboarded — route by role ───────────────────────────────
    if (user.isParent) {
      return const ParentDashboardScreen();
    }
    return const ChildDashboardScreen();
  }
}