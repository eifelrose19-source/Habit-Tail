import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

final taskServiceProvider = Provider((ref) => TaskService()); 

class TaskNotifier extends Notifier<List<TaskModel>> {
  StreamSubscription<List<TaskModel>>? _subscription; // Changed to List<TaskModel>

  @override
  List<TaskModel> build() {
    ref.onDispose(() => _subscription?.cancel());
    return [];
  }

  void watchFamilyTasks(String familyId) {
    _subscription?.cancel();
    // Listening through service instead of direct Firestore call 
    _subscription = ref.read(taskServiceProvider).watchFamilyTasks(familyId).listen((tasks) {
      state = tasks;
    });
  }

  Future<void> addTask(TaskModel task) async { 
    await ref.read(taskServiceProvider).createTask(task); 
  }

  Future<void> editTask(TaskModel task) async { 
    await ref.read(taskServiceProvider).updateTask(task); 
  }

  Future<void> removeTask(String taskId) async { 
    await ref.read(taskServiceProvider).deleteTask(taskId); 
  }
}

final taskProvider =
    NotifierProvider<TaskNotifier, List<TaskModel>>(() => TaskNotifier());