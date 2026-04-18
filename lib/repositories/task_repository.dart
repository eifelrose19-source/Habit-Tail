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

  Stream<List<TaskModel>> watchChildTasks(String familyID, String childId) {
    return _db
      .collection('tasks')
      .where('family_id', isEqualTo: familyId)
      .where('assigned_to', arrayContains: childId)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList());
  }
  /// Live stream of tasks pending parent approval
  /// Used by parent dashboard notification badge
  Stream<List<TaskModel>> watchPendingApprovalTasks(String familyId) {
    return _db
      .collection('tasks')
      .where('family_id', isEqualTo: familyId)
      .where('status', isEqualTo: 'pending_approval')
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

  /// Child marks task complete - moves to pending_approval
  /// Parent must approve before points are awarded
Future<void> submitForApproval(String taskId) {
  return _db.collection('tasks').doc(taskId).update({
    'status': 'pending_approval',
  });
}
/// Parent rejects task - returns to todo with optional note
Future<void> rejectTask(String taskId) {
  return _db.collection('tasks').doc(taskId).update({
    'status': 'todo',
  });
}
/// Deletes all tasks linked to a specific pet_id 
/// Is used when a pet is deleted
Future<void> deleteTasksByPet(String petId) async {
  final snapshot = await _db
    .collection('tasks')
    .where('pet_id', isEqualTo: petId)
    .get();
  
  final batch = _db.batch();
  for (final doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();
}
}