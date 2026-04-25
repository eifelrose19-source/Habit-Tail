import '../models/pet_model.dart';
import '../repositories/pet_repository.dart';

class PetService {
  final PetRepository _repository = PetRepository();
  // TaskService no longer needed here as repository handles batch delete

  /// Streams all pets for a family
  Stream<List<PetModel>> watchFamilyPets(String familyId) {
    return _repository.watchPets(familyId);
  }

  /// Adds a new pet to the family
  Future<void> createPet(PetModel pet) async {
    await _repository.createPet(pet);
  }

  /// Updates pet info — vet details, meds, etc.
  Future<void> updatePet(String petId, Map<String, dynamic> data) async {
    await _repository.updatePet(petId, data);
  }

  /// Deletes pet and all tasks linked to it via repository batch
  Future<void> deletePet(String petId) async {
    await _repository.deletePet(petId);
  }
}