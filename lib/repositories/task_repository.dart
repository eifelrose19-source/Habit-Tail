import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskRepository {
  final TaskService _service = TaskService();

  /// Live stream of all tasks in a family — screens should use this
  /// to stay in sync with Firestore changes automatically.
  Stream<List<TaskModel>> watchTasks(String familyId) {
    return _service.getTaskStream(familyId).map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// One-time fetch of a single task — use for checks, not live screens.
  Future<TaskModel?> getTask(String familyId, String taskId) async {
    final doc = await _service.getTaskDoc(familyId, taskId);
    if (!doc.exists) return null;
    return TaskModel.fromMap(doc.data()!, doc.id);
  }

  /// Creates a new task document in Firestore.
  Future<void> createTask(String familyId, TaskModel task) {
    return _service.createTask(familyId, task.id, task.toMap());
  }

  /// Updates an existing task document in Firestore.
  Future<void> updateTask(
      String familyId, String taskId, Map<String, dynamic> data) {
    return _service.updateTask(familyId, taskId, data);
  }

  /// Deletes a task document from Firestore.
  Future<void> deleteTask(String familyId, String taskId) {
    return _service.deleteTask(familyId, taskId);
  }

  /// Marks a task as completed in Firestore.
  /// Point awarding should be handled separately in the controller
  /// after this call succeeds.
  Future<void> completeTask(String familyId, String taskId) {
    return _service.updateTask(familyId, taskId, {
      'status': 'completed',
      'completedAt': DateTime.now().toIso8601String(),
    });
  }
}