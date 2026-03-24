import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/pet_model.dart';
import '../models/task_model.dart';
import '../models/reward_model.dart';
import '../models/redemption_log_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Collection References with Converters ---

  CollectionReference<UserModel> get users => _db
      .collection('users')
      .withConverter<UserModel>(
        fromFirestore: (snapshot, _) => UserModel.fromFirestore(snapshot),
        toFirestore: (model, _) => model.toFirestore(),
      );

  CollectionReference<PetModel> get pets => _db
      .collection('pets')
      .withConverter<PetModel>(
        fromFirestore: (snapshot, _) => PetModel.fromFirestore(snapshot),
        toFirestore: (model, _) => model.toFirestore(),
      );

  CollectionReference<TaskModel> get tasks => _db
      .collection('tasks')
      .withConverter<TaskModel>(
        fromFirestore: (snapshot, _) => TaskModel.fromFirestore(snapshot),
      // Ensure your TaskModel has this method or rename it to toMap() if needed
        toFirestore: (model, _) => model.toFirestore(),
      );

  CollectionReference<RewardModel> get rewards => _db
      .collection('rewards')
      .withConverter<RewardModel>(
        fromFirestore: (snapshot, _) => RewardModel.fromFirestore(snapshot),
        toFirestore: (model, _) => model.toFirestore(),
      );

  CollectionReference<RedemptionLogModel> get redemptionLogs => _db
      .collection('redemption_log')
      .withConverter<RedemptionLogModel>(
        fromFirestore: (snapshot, _) => RedemptionLogModel.fromFirestore(snapshot),
        toFirestore: (model, _) => model.toFirestore(),
      );

  // --- STREAM METHODS ---

  // Stream a single User
  Stream<UserModel?> streamUser(String userId) {
    return users.doc(userId).snapshots().map((doc) => doc.data());
  }

  // Stream all Pets for a Family
  Stream<List<PetModel>> streamFamilyPets(String familyId) {
    return pets
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Stream all Tasks for a Family
  Stream<List<TaskModel>> streamTasks(String familyId) {
    return tasks
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Stream all Rewards for a Family
  Stream<List<RewardModel>> streamRewards(String familyId) {
    return rewards
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}