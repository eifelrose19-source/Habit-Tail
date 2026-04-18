import '../models/reward_model.dart';
import '../repositories/reward_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/redemption_log_repository.dart';
import '../models/redemption_log_model.dart';

class RewardService {
  final RewardRepository _rewardRepository = RewardRepository();
  final RedemptionLogRepository _logRepository = RedemptionLogRepository();
  final UserRepository _userRepository = UserRepository();

  /// Streams all rewards for a family
  Stream<List<RewardModel>> watchFamilyRewards(String familyId) {
    return _rewardRepository.watchRewards(familyId);
  }

  /// Creates a new reward
  Future<void> createReward(RewardModel reward) async {
    await _rewardRepository.createReward(reward);
  }

  /// Updates reward fields
  Future<void> updateReward(String rewardId, Map<String, dynamic> data) async {
    await _rewardRepository.updateReward(rewardId, data);
  }

  /// Toggles reward visibility to children
  Future<void> toggleRewardActive(String rewardId, bool isActive) async {
    await _rewardRepository.updateReward(rewardId, {'is_active': isActive});
  }

  /// Deletes a reward
  Future<void> deleteReward(String rewardId) async {
    await _rewardRepository.deleteReward(rewardId);
  }

  /// Child redeems a reward.
  /// Checks points, deducts cost, creates redemption log — all in one call.
  /// Points deduction happens here. Parent approval is separate (Phase 4 Step P).
  Future<void> redeemReward({
    required String familyId,
    required String childId,
    required String parentId,
    required String rewardId,
  }) async {
    // Fetch reward to get cost
    final reward = await _rewardRepository.getReward(rewardId);
    if (reward == null) throw Exception('Reward not found.');
    if (!reward.isActive || !reward.isAvailable) {
      throw Exception('Reward is not available.');
    }

    // Fetch child to check points balance
    final child = await _userRepository.getUser(childId);
    if (child == null) throw Exception('Child not found.');
    if (child.totalPoints < reward.cost) {
      throw Exception('Not enough points.');
    }

    // Deduct points from child
    await _userRepository.addPoints(childId, -reward.cost);

    // Create redemption log with status pending_approval
    final log = RedemptionLogModel(
      logId: '',               // Firestore generates this on create
      childId: childId,
      parentId: parentId,
      familyId: familyId,
      rewardId: rewardId,
      status: 'pending_approval',
      cost: reward.cost,
      timestamp: DateTime.now(),
    );

    await _logRepository.createRedemptionLog(log);
  }
}