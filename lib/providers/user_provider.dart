import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _repo = UserRepository();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<UserModel?>? _userSubscription;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isParent => _user?.isParent ?? false;
  bool get isLoggedIn => _user != null;

  /// Start listening to user changes in real-time
  void startListening(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Cancel existing subscription if any
    _userSubscription?.cancel();

    _userSubscription = _repo.watchUser(userId).listen(
      (updatedUser) {
        _user = updatedUser;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Stop listening to user changes (call when user logs out)
  void stopListening() {
    _userSubscription?.cancel();
    _userSubscription = null;
    _user = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Fetch user once (no real-time updates)
  Future<void> fetchUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _repo.getUser(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _repo.updateUser(userId, data);
      // The real-time listener will automatically update _user
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Add points to user
  Future<void> addPoints(String userId, int points) async {
    try {
      await _repo.addPoints(userId, points);
      // The real-time listener will automatically update _user
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}