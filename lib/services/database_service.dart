import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_model.dart';
import '../models/user_model.dart';
import '../models/pet_model.dart';
import '../models/task_model.dart';
import '../models/reward_model.dart';
import '../models/pet_vet_info_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// --- TOP LEVEL COLLECTIONS ---

  // Reference for the Families collection
  CollectionReference<FamilyModel> get families =>
      _db.collection('families').withConverter<FamilyModel>(
            fromFirestore: (snapshot, _) => FamilyModel.fromFirestore(snapshot),
            toFirestore: (model, _) => model.toFirestore(),
          );

  // Reference for the Users collection
  CollectionReference<UserModel> get users =>
      _db.collection('users').withConverter<UserModel>(
            fromFirestore: (snapshot, _) => UserModel.fromFirestore(snapshot),
            toFirestore: (model, _) => model.toFirestore(),
          );

  /// --- NESTED SUB-COLLECTIONS ---
  /// These match database structure: families -> {familyID} -> {sub-collection}

  // Reference for Pets nested under a Family
  CollectionReference<PetModel> pets(String familyId) =>
      families.doc(familyId).collection('pets').withConverter<PetModel>(
            fromFirestore: (snapshot, _) => PetModel.fromFirestore(snapshot),
            toFirestore: (model, _) => model.toFirestore(),
          );

  // Reference for Tasks nested under a Family
  CollectionReference<TaskModel> tasks(String familyId) =>
      families.doc(familyId).collection('tasks').withConverter<TaskModel>(
            fromFirestore: (snapshot, _) => TaskModel.fromFirestore(snapshot),
            toFirestore: (model, _) => model.toFirestore(),
          );

  // Reference for Rewards nested under a Family
  CollectionReference<RewardModel> rewards(String familyId) =>
      families.doc(familyId).collection('rewards').withConverter<RewardModel>(
            fromFirestore: (snapshot, _) => RewardModel.fromFirestore(snapshot),
            toFirestore: (model, _) => model.toFirestore(),
          );

  // Reference for Vet Info nested under a Pet
  CollectionReference<PetVetInfoModel> vetInfo(String familyId, String petId) =>
      pets(familyId).doc(petId).collection('vet_info').withConverter<PetVetInfoModel>(
            fromFirestore: (snapshot, _) => PetVetInfoModel.fromFirestore(snapshot),
            toFirestore: (model, _) => model.toFirestore(),
          );

  /// --- STREAM METHODS ---

  // Stream a single Family
  Stream<FamilyModel?> streamFamily(String familyId) {
    return families.doc(familyId).snapshots().map((doc) => doc.data());
  }

  // Stream a single User
  Stream<UserModel?> streamUser(String userId) {
    return users.doc(userId).snapshots().map((doc) => doc.data());
  }

  // Stream a single Pet (Updates your current method)
  Stream<PetModel?> streamPet(String familyId, String petId) {
    return pets(familyId).doc(petId).snapshots().map((doc) => doc.data());
  }

  // Stream all Tasks for a Family
  Stream<List<TaskModel>> streamTasks(String familyId) {
    return tasks(familyId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Stream all Rewards for a Family
  Stream<List<RewardModel>> streamRewards(String familyId) {
    return rewards(familyId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }
}