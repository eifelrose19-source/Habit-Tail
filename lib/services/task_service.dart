import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Constants ───────────────────────────────────────────────
  static const int _minPointsPerTask = 1;
  static const int _maxPointsPerTask = 100;

  // ─── Helpers ────────────────────────────────────────────────

  /// Pointing to the root 'tasks' collection
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

  /// Helper to get current user data for role validation
  Future<Map<String, dynamic>?> _getCurrentUserData() async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final userSnapshot = await _db.collection('users').doc(userId).get();
    return userSnapshot.data();
  }

  // ─── Streams ─────────────────────────────────────────────────

  /// Streams tasks filtered by the family_id field
  Stream<QuerySnapshot<Map<String, dynamic>>> getTaskStream(String familyId) {
    return _db
        .collection('tasks')
        .where('family_id', isEqualTo: familyId)
        .snapshots();
  }

  // ─── Parent: Create Task ──────────────────────────────────────

  Future<void> createTask({
    required String familyId,
    required String assignedTo,
    required String name,
    required int points,
  }) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No signed-in user.');

    final userData = await _getCurrentUserData();
    if (userData?['is_parent'] != true) {
      throw Exception('Only a Parent can create tasks.');
    }

    final int clampedPoints = points.clamp(_minPointsPerTask, _maxPointsPerTask);

    await _db.collection('tasks').add({
      'name': name,
      'points': clampedPoints,
      'assigned_to': assignedTo,
      'family_id': familyId,
      'created_by': userId,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // ─── Child: Submit Task ───────────────────────────────────────

  Future<void> submitTaskCompletion(String taskId) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No signed-in user.');

    final taskSnapshot = await _getVerifiedTask(taskId);
    final data = taskSnapshot.data() as Map<String, dynamic>?;

    if (data?['assigned_to'] != userId) {
      throw Exception('You are not assigned to this task.');
    }

    if (data?['status'] != 'pending') {
      throw Exception('Task cannot be submitted. Current status: ${data?['status']}');
    }

    await _taskRef(taskId).update({
      'status': 'pending_approval',
      'submitted_at': FieldValue.serverTimestamp(),
    });
  }

  // ─── Parent: Approve Task ─────────────────────────────────────

  Future<void> approveTask(String taskId) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No signed-in user.');

    final userData = await _getCurrentUserData();
    if (userData?['is_parent'] != true) {
      throw Exception('Only a Parent can approve tasks.');
    }

    await _db.runTransaction((transaction) async {
      final taskRef = _taskRef(taskId);
      final taskSnapshot = await transaction.get(taskRef);

      final data = taskSnapshot.data() as Map<String, dynamic>?;
      if (data?['status'] != 'pending_approval') {
        throw Exception('Task is not awaiting approval.');
      }

      final String? assignedTo = data?['assigned_to'] as String?;
      final int points = data?['points'] as int? ?? 0;

      final userRef = _db.collection('users').doc(assignedTo);

      // Atomic Update: Mark task complete AND reward points
      transaction.update(taskRef, {
        'status': 'completed',
        'approved_by': userId,
        'approved_at': FieldValue.serverTimestamp(),
      });

      transaction.update(userRef, {
        'total_points': FieldValue.increment(points),
      });
    });
  }

  // ─── Generic Update ──────────────────────────────────────────

  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    await _getVerifiedTask(taskId);
    await _taskRef(taskId).update(data);
  }
}