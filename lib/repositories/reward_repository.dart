import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward_model.dart';

class RewardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Streams rewards for a family, filtered by family_id
  Stream<List<RewardModel>> watchRewards(String familyId) {
    return _firestore
        .collection('rewards')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RewardModel.fromFirestore(doc))
            .toList());
  }

  /// Gets a single reward by its unique document ID
  Future<RewardModel?> getReward(String rewardId) async {
    final doc = await _firestore.collection('rewards').doc(rewardId).get();
    if (!doc.exists) return null;
    return RewardModel.fromFirestore(doc);
  }

  /// Adds a new reward to the top-level rewards collection
  Future<void> createReward(RewardModel reward) async {
    await _firestore
        .collection('rewards')
        .add(reward.toFirestore());
  }

  /// Updates reward details using only the document ID
  Future<void> updateReward(String rewardId, Map<String, dynamic> data) async {
    await _firestore
        .collection('rewards')
        .doc(rewardId)
        .update(data);
  }

  /// Deletes a reward document
  Future<void> deleteReward(String rewardId) async {
    await _firestore.collection('rewards').doc(rewardId).delete();
  }
}