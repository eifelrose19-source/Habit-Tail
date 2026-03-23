import 'package:cloud_firestore/cloud_firestore.dart';

class RewardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> streamRewards(String familyId) {
    return _db
        .collection('Families')
        .doc(familyId)
        .collection('Rewards')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList());
  }

  Future<void> addReward(String familyId, Map<String, dynamic> data) {
    return _db
        .collection('Families')
        .doc(familyId)
        .collection('Rewards')
        .add(data);
  }

  Future<void> updateReward(
      String familyId, String rewardId, Map<String, dynamic> data) {
    return _db
        .collection('Families')
        .doc(familyId)
        .collection('Rewards')
        .doc(rewardId)
        .update(data);
  }

  Future<void> deleteReward(String familyId, String rewardId) {
    return _db
        .collection('Families')
        .doc(familyId)
        .collection('Rewards')
        .doc(rewardId)
        .delete();
  }

  /// Redeems a reward for a user — checks points, deducts cost,
  /// and creates a redemption log in a single atomic transaction.
  Future<void> redeemReward(
      String familyId, String rewardId, String userId) async {
    final rewardRef = _db
        .collection('Families')
        .doc(familyId)
        .collection('Rewards')
        .doc(rewardId);
    final userRef = _db.collection('Users').doc(userId);

    await _db.runTransaction((transaction) async {
      // Read both documents inside the transaction for consistency
      final rewardDoc = await transaction.get(rewardRef);
      if (!rewardDoc.exists) throw Exception('Reward not found');

      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) throw Exception('User not found');

      final reward = rewardDoc.data() as Map<String, dynamic>;
      final int cost = int.tryParse(
              (reward['Reward_price'] ?? '0').toString()) ??
          0;
      final int currentPoints =
          (userDoc.data()?['Total_points'] as num?)?.toInt() ?? 0;

      if (currentPoints < cost) throw Exception('Not enough points');

      // Deduct points from user
      transaction.update(userRef, {
        'Total_points': FieldValue.increment(-cost),
      });

      // Create redemption log entry
      final logRef = _db
          .collection('Families')
          .doc(familyId)
          .collection('RedemptionLog')
          .doc();

      transaction.set(logRef, {
        'Claimed_by': userId,
        'Reward_id': rewardId,
        'Reward_Timestamp': FieldValue.serverTimestamp(),
        'Status': 'Approved',
      });
    });
  }
}
