import 'package:cloud_firestore/cloud_firestore.dart';

class PetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getPetStream(String familyId) {
    return _db
        .collection('Families')
        .doc(familyId)
        .collection('Pets')
        .snapshots();
  }

  Future<void> updatePetRaw(
    String familyId,
    String petId,
    Map<String, dynamic> data,
  ) {
    return _db
        .collection('Families')
        .doc(familyId)
        .collection('Pets')
        .doc(petId)
        .update(data);
  }
}
