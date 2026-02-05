import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('Users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUser(String userId, UserModel user) async {
    await _firestore.collection('Users').doc(userId).set(user.toFirestore());
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('Users').doc(userId).update(data);
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('Users').doc(userId).delete();
  }
}