import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Constants ───────────────────────────────────────────────
  static const int _minPointsPerTask = 1;
  static const int _maxPointsPerTask = 100;

  // ─── Helpers ────────────────────────────────────────────────

  DocumentReference _taskRef(String taskId) {
    return _db.collection('tasks').doc(taskId);
  }

  Future<DocumentSnapshot> _getVerifiedTask(String taskId) async {
    final snapshot = await _taskRef(taskId).get();
    if (!snapshot.exists) {
      throw Exception('Task $taskId does not exist.');
    }
    return snapshot;
  }

  Future<Map<String, dynamic>?> _getCurrentUserData() async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final userSnapshot = await _db.collection('users').doc(userId).get();
    return userSnapshot.data();
  }

  // ─── Streams ─────────────────────────────────────────────────

  Stream<List<TaskModel>> watchFamilyTasks(String familyId) { 
    return _db
        .collection('tasks')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList()); // logic moved from repository/notifier to service
  }

  // ─── Business Logic ──────────────────────────────────────────

  Future<void> createTask(TaskModel task) async { // Refactored to accept model
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No signed-in user.');

    final int clampedPoints = task.points.clamp(_minPointsPerTask, _maxPointsPerTask);

    await _db.collection('tasks').add(task.copyWith(
      createdBy: userId,
      points: clampedPoints,
    ).toFirestore()); // logic moved from UI to service
  }

  Future<void> updateTask(TaskModel task) async { // Added model-based update
    await _taskRef(task.taskId).update(task.toFirestore()); 
  }

  Future<void> deleteTask(String taskId) async {
    await _taskRef(taskId).delete(); 
  }
}