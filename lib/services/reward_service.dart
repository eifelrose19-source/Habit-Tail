import '../models/reward_model.dart';
import '../models/redemption_log_model.dart';
import '../repositories/reward_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/redemption_log_repository.dart';

class RewardService {
  final RewardRepository _rewardRepository = RewardRepository();
  final RedemptionLogRepository _logRepository = RedemptionLogRepository();
  final UserRepository _userRepository = UserRepository();

  Stream<List<RewardModel>> watchFamilyRewards(String familyId) {
    return _rewardRepository.watchRewards(familyId);
  }

  Future<void> createReward(RewardModel reward) async {
    await _rewardRepository.createReward(reward);
  }

  Future<void> updateReward(String rewardId, Map<String, dynamic> data) async {
    await _rewardRepository.updateReward(rewardId, data);
  }

  Future<void> toggleRewardActive(String rewardId, bool isActive) async {
    await _rewardRepository.updateReward(rewardId, {'is_active': isActive});
  }

  Future<void> deleteReward(String rewardId) async {
    await _rewardRepository.deleteReward(rewardId);
  }

  Future<void> redeemReward({
    required String familyId,
    required String childId,
    required String parentId,
    required String rewardId,
  }) async {
    final reward = await _rewardRepository.getReward(rewardId);
    if (reward == null) throw Exception('Reward not found.');
    if (!reward.isActive || !reward.isAvailable) {
      throw Exception('Reward is not available.');
    }

    final child = await _userRepository.getUser(childId);
    if (child == null) throw Exception('Child not found.');
    if (child.totalPoints < reward.cost) {
      throw Exception('Not enough points.');
    }

    await _userRepository.addPoints(childId, -reward.cost);

    final log = RedemptionLogModel(
      logId: '',
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