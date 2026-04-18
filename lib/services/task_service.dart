import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
class TaskService {
  final TaskRepository _repository = TaskRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int _minPointsPerTask = 1;
  static const int _maxPointsPerTask = 100;

  /// Streams all tasks for a family — used by parent dashboard
  Stream<List<TaskModel>> watchFamilyTasks(String familyId) {
    return _repository.watchTasks(familyId);
  }

  /// Streams tasks for a specific child — used by child dashboard
  Stream<List<TaskModel>> watchChildTasks(String familyId, String childId) {
    return _repository.watchChildTasks(familyId, childId);
  }

  /// Streams tasks pending approval — used by parent notification badge
  Stream<List<TaskModel>> watchPendingApprovalTasks(String familyId) {
    return _repository.watchPendingApprovalTasks(familyId);
  }

  /// Creates a task — enforces point range and stamps createdBy
  Future<void> createTask(TaskModel task) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No signed-in user.');

    // Clamp points to valid range before saving
    final clampedTask = task.copyWith(
      createdBy: user.uid,
      points: task.points.clamp(_minPoints, _maxPoints),
    );

    await _repository.createTask(clampedTask);
  }

  /// Updates a task's fields
  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    await _repository.updateTask(taskId, data);
  }

  /// Deletes a single task
  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);
  }

  /// Child submits task for approval — status → pending_approval
  Future<void> submitForApproval(String taskId) async {
    await _repository.submitForApproval(taskId);
  }

  /// Parent approves task — status → completed, stamps last_completed
  /// Points are awarded here via userProvider in the provider layer
  Future<void> approveTask(String taskId) async {
    await _repository.approveTask(taskId);
  }

  /// Parent rejects task — status → todo
  Future<void> rejectTask(String taskId) async {
    await _repository.rejectTask(taskId);
  }

  /// Deletes all tasks linked to a pet — called when pet is deleted
  Future<void> deleteTasksByPet(String petId) async {
    await _repository.deleteTasksByPet(petId);
  }
}