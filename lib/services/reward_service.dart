import 'package:cloud_firestore/cloud_firestore.dart';

class RewardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> streamRewards(String familyId) {
    return _db
        .collection('Families')
        .doc(familyId)
        .collection('Rewards')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList());
  }

  Future<void> addReward(String familyId, Map<String, dynamic> data) {
    return _db.collection('Families').doc(familyId).collection('Rewards').add(data);
  }

  Future<void> updateReward(String familyId, String rewardId, Map<String, dynamic> data) {
    return _db.collection('Families').doc(familyId).collection('Rewards').doc(rewardId).update(data);
  }

  Future<void> deleteReward(String familyId, String rewardId) {
    return _db.collection('Families').doc(familyId).collection('Rewards').doc(rewardId).delete();
  }
}