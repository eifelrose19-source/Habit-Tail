import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isParent => user?.isParent ?? false;
  bool get isLoggedIn => user != null;

  UserState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) =>
      UserState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class UserNotifier extends Notifier<UserState> {
  final UserRepository _repo = UserRepository();
  StreamSubscription<UserModel?>? _userSubscription;

  @override
  UserState build() {
    ref.onDispose(() {
      _userSubscription?.cancel();
    });
    return const UserState();
  }

  void startListening(String userId) {
    state = state.copyWith(isLoading: true, error: null);
    _userSubscription?.cancel();
    _userSubscription = _repo.watchUser(userId).listen(
      (updatedUser) {
        state = state.copyWith(
          user: updatedUser,
          isLoading: false,
          error: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }

  void stopListening() {
    _userSubscription?.cancel();
    _userSubscription = null;
    state = const UserState();
  }

  Future<void> fetchUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final fetched = await _repo.getUser(userId);
      state = state.copyWith(user: fetched, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _repo.updateUser(userId, data);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> addPoints(String userId, int points) async {
    try {
      await _repo.addPoints(userId, points);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final userProvider = NotifierProvider<UserNotifier, UserState>(() => UserNotifier());