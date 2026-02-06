import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_model.dart';

class FamilyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>?> streamFamilyData(String familyId) {
    return _db.collection('Families').doc(familyId).snapshots().map((doc) => doc.data());
  }

  Future<void> createFamily(String familyId, FamilyModel family) {
    return _db.collection('Families').doc(familyId).set(family.toFirestore());
  }

  Future<FamilyModel?> getFamilyById(String familyId) async {
    try {
      final docSnapshot = await _db.collection('Families').doc(familyId).get();
      if (!docSnapshot.exists) {
        return null;
      }
      // ignore: unnecessary_cast
      final snapshot = docSnapshot as DocumentSnapshot<Map<String, dynamic>>;
      return FamilyModel.fromFirestore(snapshot);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateFamily(String familyId, Map<String, dynamic> data) {
    return _db.collection('Families').doc(familyId).update(data);
  }
}