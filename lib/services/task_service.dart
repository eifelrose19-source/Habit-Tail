import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

//Constants
static const int _minPointsPerTask = 1;
static const int _maxPointsPerTask = 100;

//Helpers
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
    final snapshot = await _taskRef(familyId, taskId).get();
    if (!snapshot.exists) {
      throw Exception('Task $taskId does not exist in family $familyId.');
    }
    return snapshot;
    }
    Future<String?> _getCurrentUserRole() async {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final userSnapshot = await _db
        .collection('Users')
        .doc(userId)
        .get();
      
      return (userSnapshot.data() as Map<String, dynamic>?)?['Role'] as String?;
    }
    //Streams
    Stream<QuerySnapshot> getTaskStream(String familyId) {
      return _db
        .collection('Families')
        .doc(familyId)
        .collection('Tasks')
        .snapshots();
    }
    //Parent Creates Task
    //Called by Parent to create new task, assign to child, and set its point reward. Status starts as pending
    Future<void> createTask({
      required String familyId,
      required String assignedTo,
      required String name,
      required int points,
    }) async {
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
    }
    //Child submits task, called by child to signal a task is done, moves status from pending to pending_approval.
    Future<void> submitTaskCompletion(String familyId, String taskId) async {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('No signed-in user.');

      final taskSnapshot = await _getVerifiedTask(familyId, taskId);
      final data = taskSnapshot.data() as Map<String, dynamic>?;

      //Ensures the child can only submit their own assigned task
      if (data?['assignedTo'] !=userId) {
        throw Exception('You are not assigned to this task');
      }
      final String? currentStatus = data?['status'] as String?;
      if (currentStatus != 'pending') {
        throw Exception(
          'Task cannot be submitted. Current Status: $currentStatus.',
      );
      }
      await _taskRef(familyId, taskId).update({
        'status': 'pending_approval',
        'submittedAt': FieldValue.serverTimestamp(),
      });
    }
    //Parent Approves Task. Called by parent to approve task, moves status from pending approval to completed and awards points to the child.
    Future<void> approveTask(String familyId, String taskId) async {
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

    //Award points to the child who owns the task
    final String? assignedTo = data?['assignedTo'] as String?;
    final int points = (data?['points'] as int? ?? _minPointsPerTask)
      .clamp(_minPointsPerTask, _maxPointsPerTask);
    if (assignedTo != null && points >0) {
      await _userService.addPoints(assignedTo, familyId, points);
    }
 }
 //Generic update (non-status fields)
 //Used for updating non-status fields only, such as name, or points.
 // Use [createTask], [submitTaskCompletion], and [approveTask] for the task lifecycle.
Future<void> updateTask(
  String familyId,
  String taskId,
  Map<String, dynamic> data,
) async {
  await _getVerifiedTask(familyId, taskId);
  await _taskRef(familyId, taskId).update(data);
}
}
