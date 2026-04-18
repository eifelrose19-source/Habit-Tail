import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reward_model.dart';
import '../services/reward_service.dart';
import 'user_provider.dart';

final rewardServiceProvider = Provider<RewardService>((ref) => RewardService());

// Live stream of all family rewards — used by both parent and child dashboards
final familyRewardsProvider = StreamProvider<List<RewardModel>>((ref) {
  final familyId = ref.watch(userProvider).user?.familyId ?? '';
  if (familyId.isEmpty) return const Stream.empty();
  return ref.read(rewardServiceProvider).watchFamilyRewards(familyId);
});

class RewardState {
  final bool isLoading;
  final String? error;

  const RewardState({
    this.isLoading = false,
    this.error,
  });

  RewardState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      RewardState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class RewardNotifier extends Notifier<RewardState> {
  late final RewardService _service;

  @override
  RewardState build() {
    _service = ref.read(rewardServiceProvider);
    return const RewardState();
  }

  /// Parent creates a reward
  Future<void> createReward(RewardModel reward) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.createReward(reward);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Parent updates reward details
  Future<void> updateReward(String rewardId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.updateReward(rewardId, data);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Parent toggles reward visibility
  Future<void> toggleRewardActive(String rewardId, bool isActive) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.toggleRewardActive(rewardId, isActive);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Parent deletes a reward
  Future<void> deleteReward(String rewardId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.deleteReward(rewardId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Child redeems a reward — checks points, deducts, creates log
  Future<void> redeemReward({
    required String childId,
    required String parentId,
    required String rewardId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final familyId = ref.read(userProvider).user?.familyId ?? '';
      if (familyId.isEmpty) throw Exception('No family found.');

      await _service.redeemReward(
        familyId: familyId,
        childId: childId,
        parentId: parentId,
        rewardId: rewardId,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final rewardProvider =
    NotifierProvider<RewardNotifier, RewardState>(() => RewardNotifier());