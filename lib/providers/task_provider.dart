import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';

class TaskNotifier extends Notifier<List<TaskModel>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  List<TaskModel> build() {
    ref.onDispose(() => _subscription?.cancel());
    return [];
  }

  /// Listens to all tasks for a specific family
  void watchFamilyTasks(String familyId) {
    _subscription?.cancel();

    _subscription = _firestore
        .collection('tasks')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Updates a task's status (e.g., 'todo' to 'completed')
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    await _firestore
        .collection('tasks')
        .doc(taskId)
        .update({
          'status': newStatus,
          'last_completed': FieldValue.serverTimestamp(),
        });
  }
}

final taskProvider =
    NotifierProvider<TaskNotifier, List<TaskModel>>(() => TaskNotifier());