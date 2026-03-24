import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// One-time fetch of a user's profile data from the root collection.
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data();
  }

  /// Updates specific fields on a user profile using merge
  /// to avoid overwriting existing fields.
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) {
    return _db
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  /// Deletes the user profile document from Firestore.
  /// Used during account deletion to maintain database cleanliness.
  Future<void> deleteUserProfile(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }
}