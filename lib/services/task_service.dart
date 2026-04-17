import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int _minPointsPerTask = 1;
  static const int _maxPointsPerTask = 100;

  DocumentReference _taskRef(String taskId) => _db.collection('tasks').doc(taskId);

  // Used internally to verify existence before updates
  Future<void> _verifyTaskExists(String taskId) async {
    final snapshot = await _taskRef(taskId).get();
    if (!snapshot.exists) throw Exception('Task $taskId does not exist.');
  }

  Stream<List<TaskModel>> watchFamilyTasks(String familyId) {
    return _db
        .collection('tasks')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  Future<void> createTask(TaskModel task) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No signed-in user.');

    final points = task.points.clamp(_minPointsPerTask, _maxPointsPerTask);

    await _db.collection('tasks').add(task.copyWith(
      createdBy: user.uid,
      points: points,
    ).toFirestore());
  }

  Future<void> updateTask(TaskModel task) async {
    await _verifyTaskExists(task.taskId);
    await _taskRef(task.taskId).update(task.toFirestore());
  }

  Future<void> deleteTask(String taskId) async {
    await _verifyTaskExists(taskId);
    await _taskRef(taskId).delete();
  }
}