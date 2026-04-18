import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<TaskModel>> watchTasks(String familyId) {
    return _db
        .collection('tasks')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<TaskModel>> watchChildTasks(String familyId, String childId) {
    return _db
        .collection('tasks')
        .where('family_id', isEqualTo: familyId)
        .where('assigned_to', arrayContains: childId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

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

  Future<TaskModel?> getTask(String taskId) async {
    final doc = await _db.collection('tasks').doc(taskId).get();
    if (!doc.exists) return null;
    return TaskModel.fromFirestore(doc);
  }

  Future<void> createTask(TaskModel task) {
    return _db.collection('tasks').add(task.toFirestore());
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> data) {
    return _db.collection('tasks').doc(taskId).update(data);
  }

  Future<void> deleteTask(String taskId) {
    return _db.collection('tasks').doc(taskId).delete();
  }

  Future<void> submitForApproval(String taskId) {
    return _db.collection('tasks').doc(taskId).update({
      'status': 'pending_approval',
    });
  }

  Future<void> approveTask(String taskId) {
    return _db.collection('tasks').doc(taskId).update({
      'status': 'completed',
      'last_completed': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectTask(String taskId) {
    return _db.collection('tasks').doc(taskId).update({
      'status': 'todo',
    });
  }

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