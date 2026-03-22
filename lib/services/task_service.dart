import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Constants ───────────────────────────────────────────────

  static const int _minPointsPerTask = 1;
  static const int _maxPointsPerTask = 100;

  // ─── Helpers ────────────────────────────────────────────────

  DocumentReference _taskRef(String familyId, String taskId) {
    return _db
        .collection('Families')
        .doc(familyId)
        .collection('Tasks')
        .doc(taskId);
  }

  Future<DocumentSnapshot> _getVerifiedTask(
    String familyId,
    String taskId,
  ) async {
    try {
      final snapshot = await _taskRef(familyId, taskId).get();
      if (!snapshot.exists) {
        throw Exception('Task $taskId does not exist in family $familyId.');
      }
      return snapshot;
    } catch (e) {
      print('[TaskService] _getVerifiedTask failed: $e');
      rethrow;
    }
  }

  Future<String?> _getCurrentUserRole() async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final userSnapshot = await _db
          .collection('Users')
          .doc(userId)
          .get();

      return (userSnapshot.data() as Map<String, dynamic>?)?['Role'] as String?;
    } catch (e) {
      print('[TaskService] _getCurrentUserRole failed: $e');
      rethrow;
    }
  }

  // ─── Streams ─────────────────────────────────────────────────

  Stream<QuerySnapshot> getTaskStream(String familyId) {
    return _db
        .collection('Families')
        .doc(familyId)
        .collection('Tasks')
        .snapshots();
  }

  // ─── Parent: Create Task ──────────────────────────────────────

  /// Called by a Parent to create a new task, assign it to a child,
  /// and set its point reward. Status starts as [pending].
  Future<void> createTask({
    required String familyId,
    required String assignedTo,
    required String name,
    required int points,
  }) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No signed-in user.');

      final String? role = await _getCurrentUserRole();
      if (role != 'Parent') {
        throw Exception('Only a Parent can create tasks.');
      }

      final int clampedPoints = points.clamp(_minPointsPerTask, _maxPointsPerTask);

      await _db
          .collection('Families')
          .doc(familyId)
          .collection('Tasks')
          .add({
            'name': name,
            'points': clampedPoints,
            'assignedTo': assignedTo,
            'createdBy': userId,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('[TaskService] createTask failed: $e');
      rethrow;
    }
  }

  // ─── Child: Submit Task ───────────────────────────────────────

  /// Called by a Child to signal a task is done. Moves status
  /// from [pending] → [pending_approval].
  Future<void> submitTaskCompletion(String familyId, String taskId) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No signed-in user.');

      final taskSnapshot = await _getVerifiedTask(familyId, taskId);
      final data = taskSnapshot.data() as Map<String, dynamic>?;

      if (data?['assignedTo'] != userId) {
        throw Exception('You are not assigned to this task.');
      }

      final String? currentStatus = data?['status'] as String?;
      if (currentStatus != 'pending') {
        throw Exception(
          'Task cannot be submitted. Current status: $currentStatus.',
        );
      }

      await _taskRef(familyId, taskId).update({
        'status': 'pending_approval',
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('[TaskService] submitTaskCompletion failed: $e');
      rethrow;
    }
  }

  // ─── Parent: Approve Task ─────────────────────────────────────

  /// Called by a Parent to approve a task. Moves status from
  /// [pending_approval] → [completed] and awards points to the child.
  Future<void> approveTask(String familyId, String taskId) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No signed-in user.');

      final String? role = await _getCurrentUserRole();
      if (role != 'Parent') {
        throw Exception('Only a Parent can approve tasks.');
      }

      final taskSnapshot = await _getVerifiedTask(familyId, taskId);
      final data = taskSnapshot.data() as Map<String, dynamic>?;
      final String? currentStatus = data?['status'] as String?;

      if (currentStatus != 'pending_approval') {
        throw Exception(
          'Task cannot be approved. Current status: $currentStatus.',
        );
      }

      await _taskRef(familyId, taskId).update({
        'status': 'completed',
        'approvedBy': userId,
        'approvedAt': FieldValue.serverTimestamp(),
      });

      final String? assignedTo = data?['assignedTo'] as String?;
      final int points = (data?['points'] as int? ?? _minPointsPerTask)
          .clamp(_minPointsPerTask, _maxPointsPerTask);
      if (assignedTo != null && points > 0) {
        await _userService.addPoints(assignedTo, familyId, points);
      }
    } catch (e) {
      print('[TaskService] approveTask failed: $e');
      rethrow;
    }
  }

  // ─── Generic Update (non-status fields) ───────────────────────

  /// Used for updating non-status fields only (e.g. name, points).
  /// Use [createTask], [submitTaskCompletion], and [approveTask]
  /// for the task lifecycle.
  Future<void> updateTask(
    String familyId,
    String taskId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _getVerifiedTask(familyId, taskId);
      await _taskRef(familyId, taskId).update(data);
    } catch (e) {
      print('[TaskService] updateTask failed: $e');
      rethrow;
    }
  }
}