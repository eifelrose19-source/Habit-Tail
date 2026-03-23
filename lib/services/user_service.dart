import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('Users').doc(userId).get();
    return doc.data();
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) {
    return _db
        .collection('Users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  /// Increments the user's total points by the given amount.
  /// Pass a negative value to deduct points.
  Future<void> incrementPoints(String userId, int points) {
    return _db.collection('Users').doc(userId).update({
      'totalPoints': FieldValue.increment(points),
    });
  }
}