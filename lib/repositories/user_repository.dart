import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//Updates automatically when Firestore Changes)
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

//Single Read not Real Time
Future<UserModel?> getUser(String userId) async{
  try {
    final doc = await _firestore.collection('Users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  } catch (e) {
    print('Error getting user: $e');
    rethrow; //rethrows so the caller can handle
  }
}

//Create a new user document
Future<void> createUser(String userId, UserModel user) async {
  try {
    await _firestore.collection('Users').doc(userId).set(user.toFirestore());
  } catch (e) {
    print('Error creating User: $e');
    rethrow;
  }
}

//Update specific fields
Future<void> updateUser(String userId, Map<String, dynamic> data) async {
  try {
    await _firestore.collection('Users').doc(userId).update(data);
  } catch (e) {
    print('Error updating user: $e');
    rethrow;
  }
}
//Update entire user (uses merge to avoid overwriting)
Future<void> setUser(String userId, UserModel user) async {
  try {
    await _firestore
    .collection('Users')
    .doc(userId)
    .set(user.toFirestore(), SetOptions(merge: true));
  } catch (e) {
    print('Error setting user: $e');
    rethrow;
  }
}
//Deletes a user document
Future<void> deleteUser(String userId) async {
  try {
    await _firestore.collection('Users').doc(userId).delete();
  } catch (e) {
    print('Error deleting user: $e');
    rethrow;
  }
}

//Get all users in a family
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
    print('Error getting family members: $e');
    rethrow;
  }
}

//Get all children in a family
Future<List<UserModel>> getFamilyChildren(String familyId) async {
  try{
    final snapshot = await _firestore
    .collection('Users')
    .where('Family_id', isEqualTo: familyId)
    .where('Is_parent', isEqualTo: false)
    .get();

    return snapshot.docs
    .map((doc) => UserModel.fromFirestore(doc))
    .toList();
  } catch (e) {
    print('Error getting family children: $e');
    rethrow;
  }
}
//Add points to users total
Future<void> addPoints(String userId, int points) async {
  try{
    await _firestore.collection('Users').doc(userId).update({
      'Total_points': FieldValue.increment(points),
    });
  }  catch (e) {
    print('Error adding points: $e');
    rethrow;
  }
 }
}