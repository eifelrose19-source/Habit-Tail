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
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error, // We allow error to be null to clear old errors
      );
}

class AuthNotifier extends Notifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  AuthState build() {
    // Listen to auth changes and update state
    _authStateSubscription = _auth.authStateChanges().listen((user) {
      state = AuthState(
        user: user,
        isLoading: false,
        error: null,
      );
      if (user != null) {
        ref.read(userProvider.notifier).startListening(user.uid);
      } else {
        ref.read(userProvider.notifier).stopListening();
      }
    });
    ref.onDispose(() => _authStateSubscription?.cancel());
      return const AuthState();
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(error: e.message);
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