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

  /// Deletes a pet and all its tasks and rewards atomically using a batch
  Future<void> deletePet(String petId) async {
    final batch = _db.batch();

    // 1. Reference the pet
    final petRef = _db.collection('pets').doc(petId);
    batch.delete(petRef);

    // 2. Find and delete all tasks linked to this pet_id
    final taskSnapshots = await _db
        .collection('tasks')
        .where('pet_id', isEqualTo: petId)
        .get();

    for (var doc in taskSnapshots.docs) {
      batch.delete(doc.reference);
    }

    // 3. Find and delete all rewards linked to this pet_id
    final rewardSnapshots = await _db
        .collection('rewards')
        .where('pet_id', isEqualTo: petId)
        .get();

    for (var doc in rewardSnapshots.docs) {
      batch.delete(doc.reference);
    }

    // 4. Commit the batch
    await batch.commit();
  }
}