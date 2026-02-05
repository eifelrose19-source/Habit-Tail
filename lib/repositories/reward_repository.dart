import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward_model.dart';

class RewardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<RewardModel>> watchRewards(String familyId) {
    return _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Rewards')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RewardModel.fromFirestore(doc))
            .toList());
  }

  Future<RewardModel?> getReward(String familyId, String rewardId) async {
    final doc = await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Rewards')
        .doc(rewardId)
        .get();
    if (!doc.exists) return null;
    return RewardModel.fromFirestore(doc);
  }

  Future<void> createReward(String familyId, RewardModel reward) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Rewards')
        .add(reward.toFirestore());
  }

  Future<void> updateReward(
      String familyId, String rewardId, Map<String, dynamic> data) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Rewards')
        .doc(rewardId)
        .update(data);
  }

  Future<void> deleteReward(String familyId, String rewardId) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Rewards')
        .doc(rewardId)
        .delete();
  }
}