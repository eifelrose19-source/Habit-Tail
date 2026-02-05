import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('Users').doc(userId).get();
    return doc.data();
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) {
    return _db.collection('Users').doc(userId).set(data, SetOptions(merge: true));
  }
}