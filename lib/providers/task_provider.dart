import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repo = TaskRepository();
  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;

  void startListening(String familyId) {
    _repo.watchTasks(familyId).listen((updatedTasks) {
      _tasks = updatedTasks;
      notifyListeners();
    });
  }
}
