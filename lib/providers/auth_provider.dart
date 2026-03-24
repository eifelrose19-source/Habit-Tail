import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        error: error,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  AuthState build() {
    _auth.authStateChanges().listen((user) {
      state = state.copyWith(user: user, isLoading: false, error: null);
    });
    return const AuthState();
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());