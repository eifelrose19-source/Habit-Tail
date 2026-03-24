import 'package:cloud_firestore/cloud_firestore.dart';

class PetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns a stream of pet documents filtered by the family_id field.
  Stream<QuerySnapshot<Map<String, dynamic>>> getPetStream(String familyId) {
    return _db
        .collection('pets')
        .where('family_id', isEqualTo: familyId)
        .snapshots();
  }

  /// Updates a specific pet document using its unique ID in the top-level collection.
  Future<void> updatePetRaw(
    String petId,
    Map<String, dynamic> data,
  ) {
    return _db
        .collection('pets')
        .doc(petId)
        .update(data);
  }
}