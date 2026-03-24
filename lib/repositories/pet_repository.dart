import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';

class PetRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Streams pets for a specific family
  Stream<List<PetModel>> watchPets(String familyId) {
    return _db
        .collection('pets')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PetModel.fromFirestore(doc))
            .toList());
  }

  /// Updates pet info (like meds or vet info)
  Future<void> updatePet(String petId, Map<String, dynamic> data) async {
    await _db.collection('pets').doc(petId).update(data);
  }
}