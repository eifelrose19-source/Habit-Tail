import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Live stream of all tasks in a family — screens should use this
  /// to stay in sync with Firestore changes automatically.
  Stream<List<TaskModel>> watchTasks(String familyId) {
    return _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  /// One-time fetch of a single task — use for checks, not live screens.
  Future<TaskModel?> getTask(String familyId, String taskId) async {
    final doc = await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Tasks')
        .doc(taskId)
        .get();
    if (!doc.exists) return null;
    return TaskModel.fromFirestore(doc);
  }

  /// Creates a new task document in Firestore.
  Future<void> createTask(String familyId, TaskModel task) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Tasks')
        .add(task.toFirestore());
  }

  /// Updates an existing task document in Firestore.
  Future<void> updateTask(
      String familyId, String taskId, Map<String, dynamic> data) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Tasks')
        .doc(taskId)
        .update(data);
  }

  /// Deletes a task document from Firestore.
  Future<void> deleteTask(String familyId, String taskId) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Tasks')
        .doc(taskId)
        .delete();
  }

  /// Marks a task as completed in Firestore.
  /// Point awarding should be handled separately in the controller
  /// after this call succeeds.
  Future<void> completeTask(String familyId, String taskId) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Tasks')
        .doc(taskId)
        .update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
}
