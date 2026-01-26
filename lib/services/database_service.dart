import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Pet> streamPet(String familyID, String petID) {
    return _db
        .collection('families')
        .doc(familyID)
        .collection('pets')
        .doc(petID)
        .snapshots()
        .map((doc) => Pet.fromFirestore(doc));
  }
}