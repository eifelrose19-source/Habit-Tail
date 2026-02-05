import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_model.dart';

class FamilyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<FamilyModel?> watchFamily(String familyId) {
    return _firestore
        .collection('Families')
        .doc(familyId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return FamilyModel.fromFirestore(snapshot);
    });
  }

  Future<FamilyModel?> getFamily(String familyId) async {
    final doc = await _firestore.collection('Families').doc(familyId).get();
    if (!doc.exists) return null;
    return FamilyModel.fromFirestore(doc);
  }

  Future<void> createFamily(String familyId, FamilyModel family) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .set(family.toFirestore());
  }

  Future<void> updateFamily(String familyId, Map<String, dynamic> data) async {
    await _firestore.collection('Families').doc(familyId).update(data);
  }

  Future<void> deleteFamily(String familyId) async {
    await _firestore.collection('Families').doc(familyId).delete();
  }
}