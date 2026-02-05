import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>?> streamFamilyData(String familyId) {
    return _db.collection('Families').doc(familyId).snapshots().map((doc) => doc.data());
  }

  Future<void> updateFamily(String familyId, Map<String, dynamic> data) {
    return _db.collection('Families').doc(familyId).update(data);
  }
}