import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';


final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

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
  late final UserRepository _repository;

  StreamSubscription<UserModel?>? _userSubscription;

  @override
  UserState build() {
    _repository = ref.read(userRepositoryProvider);
    ref.onDispose(() => _userSubscription?.cancel());
    return const UserState();
  }

  /// Listens to the specific user document in the 'users' collection.
  void startListening(String userId) {
    state = state.copyWith(isLoading: true, error: null);
    _userSubscription?.cancel();

    _userSubscription = _repository.watchUser(userId).listen(
      (user) {
        if (user != null) {
          state = state.copyWith(user: user, isLoading: false);
        } else {
          state = state.copyWith(isLoading: false, error: 'User not found');
        }
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: error.toString());
      },
    );
  }

  /// Updates user points (e.g., when a task is approved).
  Future<void> addPoints(String userId, int points) async {
    try {
      await _repository.addPoints(userId, points);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Deducts user points (e.g., when a reward is claimed).
  Future<void> subtractPoints(String userId, int points) async {
    try {
      await _repository.addPoints(userId, -points);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void stopListening() {
    _userSubscription?.cancel();
    _userSubscription = null;
    state = const UserState();
  }
}

final userProvider =
    NotifierProvider<UserNotifier, UserState>(() => UserNotifier());

