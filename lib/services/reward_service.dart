import 'package:cloud_firestore/cloud_firestore.dart';

class RewardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Streams rewards filtered by family_id field.
  Stream<List<Map<String, dynamic>>> streamRewards(String familyId) {
    return _db
        .collection('rewards')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList());
  }

  /// Adds a new reward to the root collection.
  Future<void> addReward(Map<String, dynamic> data) {
    return _db.collection('rewards').add(data);
  }

  /// Updates reward details using the unique document ID.
  Future<void> updateReward(String rewardId, Map<String, dynamic> data) {
    return _db.collection('rewards').doc(rewardId).update(data);
  }

  /// Deletes a reward document.
  Future<void> deleteReward(String rewardId) {
    return _db.collection('rewards').doc(rewardId).delete();
  }

  /// Redeems a reward for a user. Checks points, deducts cost,
  /// and creates a redemption log in a single atomic batch.
  Future<void> redeemReward(
      String familyId, String rewardId, String userId) async {
    // Step 1: Get the reward from root collection
    final rewardDoc = await _db.collection('rewards').doc(rewardId).get();

    if (!rewardDoc.exists) throw Exception('Reward not found');

    final reward = rewardDoc.data() as Map<String, dynamic>;
    final int cost = (reward['point_cost'] as num?)?.toInt() ?? 0;

    // Step 2: Get the user's current points from 'users' collection
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) throw Exception('User not found');

    final int currentPoints = (userDoc.data()?['total_points'] as num?)?.toInt() ?? 0;

    // Step 3: Check if user can afford it
    if (currentPoints < cost) throw Exception('Not enough points');

    // Step 4: Run point deduction and redemption log atomically
    final batch = _db.batch();

    // Deduct points from user
    final userRef = _db.collection('users').doc(userId);
    batch.update(userRef, {'total_points': FieldValue.increment(-cost)});

    // Create redemption log entry in root collection
    final logRef = _db.collection('redemption_log').doc();

    batch.set(logRef, {
      'family_id': familyId,
      'reward_id': rewardId,
      'reward_name': reward['name'],
      'user_id': userId,
      'point_cost': cost,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}