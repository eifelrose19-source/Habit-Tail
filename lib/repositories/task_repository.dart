import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Live stream of all tasks in a family filtered by family_id.
  Stream<List<TaskModel>> watchTasks(String familyId) {
    return _db
        .collection('tasks')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  /// One-time fetch of a single task using the document ID.
  Future<TaskModel?> getTask(String taskId) async {
    final doc = await _db.collection('tasks').doc(taskId).get();
    if (!doc.exists) return null;
    return TaskModel.fromFirestore(doc);
  }

  /// Creates a new task document in the root tasks collection.
  Future<void> createTask(TaskModel task) {
    return _db.collection('tasks').add(task.toFirestore());
  }

  /// Updates an existing task document using lowercase keys.
  Future<void> updateTask(String taskId, Map<String, dynamic> data) {
    return _db.collection('tasks').doc(taskId).update(data);
  }

  /// Deletes a task document from Firestore.
  Future<void> deleteTask(String taskId) {
    return _db.collection('tasks').doc(taskId).delete();
  }

  /// Marks a task as completed and sets the timestamp.
  Future<void> completeTask(String taskId) {
    return _db.collection('tasks').doc(taskId).update({
      'status': 'completed',
      'last_completed': FieldValue.serverTimestamp(),
    });
  }
}