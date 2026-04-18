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
/// One-time fetch of a single pet
 Future<PetModel?> getPet(String petId) async {
    final doc = await _db.collection('pets').doc(petId).get();
    if (!doc.exists) return null;
    return PetModel.fromFirestore(doc);
  }
/// Adds a new pet document
  Future<void> createPet(PetModel pet) async {
    await _db.collection('pets').add(pet.toFirestore());
  }
/// Updates pet_fields
  Future<void> updatePet(String petId, Map<String, dynamic> data) async {
    await _db.collection('pets').doc(petId).update(data);
  }
/// Deletes a pet document
  Future<void> deletePet(String petId) async {
    await _db.collection('pets').doc(petId).delete();
  }
}