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
      return UserModel.fromFirestore(
        snapshot as DocumentSnapshot<Map<String, dynamic>>);
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
    return UserModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
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

  /// Atomically increments/decrements points as total_points
  Future<void> addPoints(String userId, int points) async {
    await _firestore.collection('users').doc(userId).update({
      'total_points': FieldValue.increment(points),
    });
  }

  /// One-time fetch of children in a family for the parent dashboard
  Future<List<UserModel>> getFamilyChildren(String familyId) async {
    final snapshot = await _firestore
        .collection('users')
        .where('family_id', isEqualTo: familyId)
        .where('role', isEqualTo: 'child') 
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  /// Fetches unclaimed slots for a given family code, used in WhoAreYouScreen
  Future<List<UserModel>> fetchAvailableSlots(String familyId) async {
    final snapshot = await _firestore
    .collection('users')
    .where('family_id', isEqualTo: familyId)
    .where('claimed', isEqualTo: false)
    .get();
  return snapshot.docs
    .map((doc) =>
      UserModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
    .toList();
  }

  /// Batch-Writes the creators own doc + all member slots
  /// Called by AuthProvider when a user sets up a new family
  Future<void> setupFamily(
    String creatorId, UserModel creatorDoc, List<UserModel> memberSlots) async {
      final batch = _firestore.batch();

  /// Write the creators own doc when claimed: true
  final creatorRef = _firestore.collection('users').doc(creatorId);
  batch.set(creatorRef, creatorDoc.toFirestore(), SetOptions(merge: true));
  /// Write each seeded slot as a new auto-ID doc with claimed: false
  for (final slot in memberSlots) {
    final slotRef = _firestore.collection('users').doc();
    batch.set(slotRef, slot.toFirestore());
  }
  await batch.commit();
}

/// Claims a slot for a joining user
/// Sets the uid and flips claimed: true atomically
Future<void> claimSlot(String slotDocId, String uid) async {
  await _firestore.collection('users').doc(slotDocId).update({
    'uid': uid,
    'claimed': true,
  });
}
///Finds claimed parent doc to verify Parental PIN
///Used during WhoAreYou when parent role is selected
Future<bool> verifyParentalPin(String familyId, String enteredPin) async {
  final snapshot = await _firestore
  .collection('users')
  .where('family_id', isEqualTo: familyId)
  .where('role', isEqualTo: 'parent')
  .where('claimed', isEqualTo: true)
  .limit(1)
  .get();

  if (snapshot.docs.isEmpty) return false;
  final storedPin = snapshot.docs.first.data()['parentalPin'] as String?;
  return storedPin == enteredPin; 
}
  /// Deletes a user document
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}