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

  /// Updates a specific pet document 
  Future<void> updatePetRaw(String petId, Map<String, dynamic> data) {
    return _db.collection('pets').doc(petId).update(data);
  }
  Future<void> deletePetAndTasks(String petId, String petName) async {
    final batch = _db.batch();

    batch.delete(_db.collection('pets').doc(petId));

    final taskDocs = await _db
      .collection('tasks')
      .where('pet_name', isEqualTo: petName)
      .get();

    for (var doc in taskDocs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}