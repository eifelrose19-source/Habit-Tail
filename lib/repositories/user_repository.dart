import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Live stream of a single user — screens should use this
  /// to stay in sync with Firestore changes automatically.
  Stream<UserModel?> watchUser(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return UserModel.fromFirestore(snapshot);
    });
  }

  /// Live stream of all family members — use for screens
  /// that display the family member list in real time.
  Stream<List<UserModel>> watchFamilyMembers(String familyId) {
    return _firestore
        .collection('Users')
        .where('Family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  /// One-time fetch of a single user — use for checks, not live screens.
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new user document in Firestore.
  Future<void> createUser(String userId, UserModel user) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .set(user.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// Updates specific fields on a user document.
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('Users').doc(userId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Replaces the entire user document using merge to avoid overwriting fields.
  Future<void> setUser(String userId, UserModel user) async {
    try {
      await _firestore
          .collection('Users')
          .doc(userId)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes a user document from Firestore.
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('Users').doc(userId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// One-time fetch of all users in a family.
  Future<List<UserModel>> getFamilyMembers(String familyId) async {
    try {
      final snapshot = await _firestore
          .collection('Users')
          .where('Family_id', isEqualTo: familyId)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// One-time fetch of all children in a family.
  Future<List<UserModel>> getFamilyChildren(String familyId) async {
    try {
      final snapshot = await _firestore
          .collection('Users')
          .where('Family_id', isEqualTo: familyId)
          .where('Is_parent', isEqualTo: false)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Atomically increments a user's total points.
  /// Pass a negative value to deduct points.
  Future<void> addPoints(String userId, int points) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'Total_points': FieldValue.increment(points),
      });
    } catch (e) {
      rethrow;
    }
  }
}
