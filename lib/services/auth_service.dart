import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'package:flutter/foundation.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // --- Getters ---
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool isSignedIn() => _auth.currentUser != null;

  /// Refreshes the ID Token to fetch the latest Custom Claims (like family_id).
  Future<void> refreshFamilyToken() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final tokenResult = await user.getIdTokenResult(true);
      final claims = tokenResult.claims;

      if (claims != null && claims.containsKey('family_id')) {
        debugPrint("Success: family_id found in token: ${claims['family_id']}");
      } else {
        debugPrint("Debug: family_id is currently missing from token.");
      }
    }
  }

  /// Sign in with email and password.
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await refreshFamilyToken();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign up and create user document in Firestore.
  Future<UserModel> signUpAndCreateUser({
    required String email,
    required String password,
    required String name,
    required String familyId,
    required bool isParent,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = credential.user!.uid;

      final newUser = UserModel(
        userId: userId,
        familyId: familyId,
        name: name,
        totalPoints: 0,
        isParent: isParent,
      );

      // Save to Firestore via UserService
      await _userService.updateUserProfile(userId, newUser.toFirestore());
      await credential.user!.updateDisplayName(name);

      // Wait for Cloud Function to assign claims
      await Future.delayed(const Duration(seconds: 2));
      await refreshFamilyToken();

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Checks whether a Firestore user document exists for the current Auth user.
  Future<bool> userRecordExists() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    final profile = await _userService.getUserProfile(userId);
    return profile != null;
  }

  /// Syncs the Firestore user document for the current Auth user.
  Future<void> syncUserRecord({
    required String name,
    required String familyId,
    required bool isParent,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No user logged in');

    final existingUser = await _userService.getUserProfile(userId);
    if (existingUser != null) return;

    final newUser = UserModel(
      userId: userId,
      familyId: familyId,
      name: name,
      totalPoints: 0,
      isParent: isParent,
    );

    await _userService.updateUserProfile(userId, newUser.toFirestore());

    await Future.delayed(const Duration(seconds: 2));
    await refreshFamilyToken();
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sends a verification email to the new address before updating.
  /// User must be recently authenticated before calling this.
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Updates password. Requires recent login — call reauthenticate() first.
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Delete user account (both Auth and Firestore)
  Future<void> deleteAccount() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _userService.deleteUserProfile(userId);
        await _auth.currentUser?.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> reauthenticate(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        return 'Authentication error: ${e.message ?? 'Unknown error'}';
    }
  }
}