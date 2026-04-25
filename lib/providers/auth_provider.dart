import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = true,
    this.error,
  });

  bool get isAuthenticated => user != null;
  String? get userId => user?.uid;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  AuthState build() {
    _authStateSubscription = _auth.authStateChanges().listen((user) async {
      if (user == null) {
        ref.read(userProvider.notifier).stopListening();
        state = const AuthState(user: null, isLoading: false);
      } else {
        try {
          // Logic: Ensure DB record exists, then start the user stream
          await ref.read(userRepositoryProvider).ensureUserExists(user);

          state = AuthState(user: user, isLoading: false, error: null);
          ref.read(userProvider.notifier).startListening(user.uid);
        } catch (e) {
          state = state.copyWith(isLoading: false, error: e.toString());
        }
      }
    });
    ref.onDispose(() => _authStateSubscription?.cancel());
    return const AuthState();
  }

  Future<void> signOut() async {
    try {
      ref.read(userProvider.notifier).stopListening();
      state = const AuthState(user: null, isLoading: false);
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      await _auth.signOut();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception('Sign in cancelled');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());