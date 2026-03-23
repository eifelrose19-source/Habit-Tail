import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import 'dart:developer' as developer;

class TaskProvider with ChangeNotifier {
  final TaskRepository _repo = TaskRepository();
  StreamSubscription<List<TaskModel>>? _subscription;
  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;

  void startListening(String familyId) {
    _subscription?.cancel();
    _subscription = _repo.watchTasks(familyId).listen(
      (updatedTasks) {
        _tasks = updatedTasks;
        notifyListeners();
      },
      onError: (error) {
        developer.log('TaskProvider stream error: $error',
            name: 'TaskProvider');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
