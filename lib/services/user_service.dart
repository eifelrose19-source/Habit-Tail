import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// One-time fetch of a user's profile data.
  /// For live updates use UserRepository.watchUser() instead.
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('Users').doc(userId).get();
    return doc.data();
  }

  /// Updates specific fields on a user profile using merge
  /// to avoid overwriting existing fields.
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) {
    return _db
        .collection('Users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }
}