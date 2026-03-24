import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskNotifier extends Notifier<List<TaskModel>> {
  final TaskRepository _repo = TaskRepository();

  @override
  List<TaskModel> build() => [];

  void startListening(String familyId) {
    _repo.watchTasks(familyId).listen((updatedTasks) {
      state = updatedTasks;
    });
  }
}

final taskProvider =
    NotifierProvider<TaskNotifier, List<TaskModel>>(() => TaskNotifier());