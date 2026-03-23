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
  /// and creates a redemption log in a single atomic batch.
  Future<void> redeemReward(
      String familyId, String rewardId, String userId) async {
    // Step 1: Get the reward
    final rewardDoc = await _db
        .collection('Families')
        .doc(familyId)
        .collection('Rewards')
        .doc(rewardId)
        .get();

    if (!rewardDoc.exists) throw Exception('Reward not found');

    final reward = rewardDoc.data() as Map<String, dynamic>;
    final int cost = reward['pointCost'] ?? 0;

    // Step 2: Get the user's current points
    final userDoc = await _db.collection('Users').doc(userId).get();
    if (!userDoc.exists) throw Exception('User not found');

    final int currentPoints = userDoc.data()?['totalPoints'] ?? 0;

    // Step 3: Check if user can afford it
    if (currentPoints < cost) throw Exception('Not enough points');

    // Step 4: Run point deduction and redemption log atomically
    final batch = _db.batch();

    // Deduct points from user
    final userRef = _db.collection('Users').doc(userId);
    batch.update(userRef, {'totalPoints': FieldValue.increment(-cost)});

    // Create redemption log entry
    final logRef = _db
        .collection('Families')
        .doc(familyId)
        .collection('RedemptionLog')
        .doc();

    batch.set(logRef, {
      'rewardId': rewardId,
      'rewardName': reward['name'],
      'userId': userId,
      'pointCost': cost,
      'redeemedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}