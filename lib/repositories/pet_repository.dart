import '../models/pet_model.dart';
import '../services/pet_service.dart';

class PetRepository {
  final PetService _service = PetService();

  Stream<List<PetModel>> watchPets(String familyId) {
    return _service.getPetStream(familyId).map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                PetModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  Future<void> updatePet(String familyId, PetModel pet) {
    return _service.updatePetRaw(familyId, pet.id, pet.toMap());
  }
}
