// user_provider.dart
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
  bool get needsFamilySetup => user != null && user!.familyId.isEmpty;
  bool get isClaimed => user?.claimed ?? false;

  UserState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
  }) =>
      UserState(
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class UserNotifier extends Notifier<UserState> {
  late final UserRepository _repository;
  StreamSubscription<UserModel?>? _userSubscription;
  bool _stopped = false; // ← guard flag

  @override
  UserState build() {
    _repository = ref.read(userRepositoryProvider);
    ref.onDispose(() => _userSubscription?.cancel());
    return const UserState();
  }

  void startListening(String userId) {
    _stopped = false;
    state = state.copyWith(isLoading: true, error: null);
    _userSubscription?.cancel();

    _userSubscription = _repository.watchUser(userId).listen(
      (user) {
        if (_stopped) return; // ← ignore events after stopListening
        if (user != null) {
          state = state.copyWith(user: user, isLoading: false);
        } else {
          state = const UserState(isLoading: false, error: null);
        }
      },
      onError: (error) {
        if (_stopped) return; // ← ignore stream close errors on sign-out
        state = state.copyWith(isLoading: false, error: error.toString());
      },
    );
  }

  Future<void> addPoints(String userId, int points) async {
    try {
      await _repository.addPoints(userId, points);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> subtractPoints(String userId, int points) async {
    try {
      await _repository.addPoints(userId, -points);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void stopListening() {
    _stopped = true; // ← set flag first
    _userSubscription?.cancel();
    _userSubscription = null;
    state = const UserState(); // isLoading: false, user: null
  }
}

final userProvider =
    NotifierProvider<UserNotifier, UserState>(() => UserNotifier());