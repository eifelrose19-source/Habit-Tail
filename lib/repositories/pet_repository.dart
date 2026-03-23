import '../models/pet_model.dart';
import '../services/pet_service.dart';

class PetRepository {
  final PetService _service = PetService();

  /// Live stream of all pets in a family — screens should use this
  /// to stay in sync with Firestore changes automatically.
  Stream<List<PetModel>> watchPets(String familyId) {
    return _service.getPetStream(familyId).map((snapshot) {
      return snapshot.docs
          .map((doc) => PetModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// One-time fetch of a single pet — use for checks, not live screens.
  Future<PetModel?> getPet(String familyId, String petId) async {
    final doc = await _service.getPetDoc(familyId, petId);
    if (!doc.exists) return null;
    return PetModel.fromMap(doc.data()!, doc.id);
  }

  /// Creates a new pet document in Firestore.
  Future<void> createPet(String familyId, PetModel pet) {
    return _service.createPet(familyId, pet.id, pet.toMap());
  }

  /// Updates an existing pet document in Firestore.
  Future<void> updatePet(String familyId, PetModel pet) {
    return _service.updatePetRaw(familyId, pet.id, pet.toMap());
  }

  /// Deletes a pet document from Firestore.
  Future<void> deletePet(String familyId, String petId) {
    return _service.deletePet(familyId, petId);
  }
}