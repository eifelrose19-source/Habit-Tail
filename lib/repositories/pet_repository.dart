import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';

class PetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Live stream of all pets in a family — screens should use this
  /// to stay in sync with Firestore changes automatically.
  Stream<List<PetModel>> watchPets(String familyId) {
    return _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Pets')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PetModel.fromFirestore(doc))
            .toList());
  }

  /// One-time fetch of a single pet — use for checks, not live screens.
  Future<PetModel?> getPet(String familyId, String petId) async {
    final doc = await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Pets')
        .doc(petId)
        .get();
    if (!doc.exists) return null;
    return PetModel.fromFirestore(doc);
  }

  /// Creates a new pet document in Firestore.
  Future<void> createPet(String familyId, PetModel pet) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Pets')
        .add(pet.toFirestore());
  }

  /// Updates an existing pet document in Firestore.
  Future<void> updatePet(String familyId, PetModel pet) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Pets')
        .doc(pet.petId)
        .update(pet.toFirestore());
  }

  /// Deletes a pet document from Firestore.
  Future<void> deletePet(String familyId, String petId) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Pets')
        .doc(petId)
        .delete();
  }
}
