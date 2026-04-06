import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Live stream of a single user
  Stream<UserModel?> watchUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return UserModel.fromFirestore(snapshot);
    });
  }

  /// Live stream of all family members using the flat family_id field
  Stream<List<UserModel>> watchFamilyMembers(String familyId) {
    return _firestore
        .collection('users')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  /// One-time fetch of a single user
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Creates or updates a user document
  Future<void> setUser(String userId, UserModel user) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  /// Updates specific fields like name or profile settings
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  /// Atomically increments/decrements points matching your lowercase key
  Future<void> addPoints(String userId, int points) async {
    await _firestore.collection('users').doc(userId).update({
      'total_points': FieldValue.increment(points),
    });
  }

  /// One-time fetch of children in a family for the parent dashboard
  Future<List<UserModel>> getFamilyChildren(String familyId) async {
    // FIXED: Changed 'is_parent' (bool) to 'role' (String) to match your Firestore
    final snapshot = await _firestore
        .collection('users')
        .where('family_id', isEqualTo: familyId)
        .where('role', isEqualTo: 'child') 
        .get();
    
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  /// Deletes a user document
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}