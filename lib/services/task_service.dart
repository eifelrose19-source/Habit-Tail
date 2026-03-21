import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getTaskStream(String familyId) {
    return _db
        .collection('Families')
        .doc(familyId)
        .collection('Tasks')
        .snapshots();
  }

  Future<void> updateTaskStatus(
    String familyId,
    String taskId,
    Map<String, dynamic> data,
  ) async {
    final DocumentReference taskRef = _db
        .collection('Families')
        .doc(familyId)
        .collection('Tasks')
        .doc(taskId);
  //Verifies the task document exists
  final DocumentSnapshot taskSnapshot = await taskRef.get();
  if (!taskSnapshot.exists) {
    throw Exception('Task $taskId does not exist in family $familyId');
  }
  //Guard against re-awarding points if task already completed
  final String? currentStatus =
    (taskSnapshot.data() as Map<String, dynamic>?)?['status'] as String?;
  final bool alreadyCompleted = currentStatus == 'completed';
  final bool isBeingCompleted = data['status'] == 'completed';

  await taskRef.update(data);

  final String? userId = _auth.currentUser?.uid;

  if (isBeingCompleted && !alreadyCompleted && userId != null) {
    await _userService.addPoints(userId, familyId);
    }
   }
}