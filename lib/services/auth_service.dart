import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepo = UserRepository();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  /// Refreshes the ID Token to fetch the latest Custom Claims (like family_id).
  /// This is essential for the Security Rules to recognize the user's family.
  Future<void> refreshFamilyToken() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Force refresh to get the latest claims from the server
      final tokenResult = await user.getIdTokenResult(true);
      final claims = tokenResult.claims;

      if (claims != null && claims.containsKey('family_id')) {
        print("Success: family_id found in token: ${claims['family_id']}");
      } else {
        print("Debug: family_id is currently missing from token. Check Cloud Functions.");
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
      
      // Refresh token on sign-in to ensure permissions are up to date
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
      // 1. Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = credential.user!.uid;

      // 2. Create UserModel
      final newUser = UserModel(
        userId: userId,
        familyId: familyId,
        name: name,
        totalPoints: 0,
        isParent: isParent,
      );

      // 3. Create user document in Firestore
      // This trigger the Cloud Function to set the Custom Claim
      await _userRepo.createUser(userId, newUser);

      // 4. Update Firebase Auth display name
      await credential.user!.updateDisplayName(name);

      // 5. Wait briefly for Cloud Function and refresh token
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
    final user = await _userRepo.getUser(userId);
    return user != null;
  }

  /// Syncs the Firestore user document for the current Auth user.
  Future<void> syncUserRecord({
    required String name,
    required String familyId,
    required bool isParent,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No user logged in');

    final existingUser = await _userRepo.getUser(userId);

    if (existingUser != null) return;

    final newUser = UserModel(
      userId: userId,
      familyId: familyId,
      name: name,
      totalPoints: 0,
      isParent: isParent,
    );

    await _userRepo.createUser(userId, newUser);

    // Wait for Cloud Function and refresh
    await Future.delayed(const Duration(seconds: 2));
    await refreshFamilyToken();
  }

  /// Sign out and clear user data
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user password
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
        await _userRepo.deleteUser(userId);
        await _auth.currentUser?.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Re-authenticate user
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

  /// Handle Firebase Auth exceptions with user-friendly messages
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