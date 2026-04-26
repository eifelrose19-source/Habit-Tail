import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import 'user_provider.dart';

final taskServiceProvider = Provider<TaskService>((ref) => TaskService());

// Updated to .family to accept petId, and passes both IDs to the service
final familyTasksProvider = StreamProvider.family<List<TaskModel>, String>((ref, petId) {
  final familyId = ref.watch(userProvider).user?.familyId ?? '';
  if (familyId.isEmpty) return const Stream.empty();
  // Now matches the new TaskService.watchFamilyTasks(familyId, petId)
  return ref.read(taskServiceProvider).watchFamilyTasks(familyId, petId);
});

// Tasks for a specific child — used by child dashboard
final childTasksProvider =
    StreamProvider.family<List<TaskModel>, String>((ref, childId) {
  final familyId = ref.watch(userProvider).user?.familyId ?? '';
  if (familyId.isEmpty) return const Stream.empty();
  return ref.read(taskServiceProvider).watchChildTasks(familyId, childId);
});

// Pending approval tasks — drives parent notification badge
final pendingApprovalTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final familyId = ref.watch(userProvider).user?.familyId ?? '';
  if (familyId.isEmpty) return const Stream.empty();
  return ref.read(taskServiceProvider).watchPendingApprovalTasks(familyId);
});

class TaskState {
  final bool isLoading;
  final String? error;

  const TaskState({
    this.isLoading = false,
    this.error,
  });

  TaskState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      TaskState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class TaskNotifier extends Notifier<TaskState> {
  late final TaskService _service;

  @override
  TaskState build() {
    _service = ref.read(taskServiceProvider);
    return const TaskState();
  }

  /// Parent creates a task and assigns to one or more children
  Future<void> createTask(TaskModel task) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.createTask(task);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Parent edits a task
  Future<void> updateTask(String taskId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.updateTask(taskId, data);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Parent deletes a task
  Future<void> deleteTask(String taskId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.deleteTask(taskId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Child submits task for approval — status → pending_approval
  Future<void> submitForApproval(String taskId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.submitForApproval(taskId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Parent approves task — status → completed, points awarded via userProvider
  Future<void> approveTask(String taskId, String childId, int points) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.approveTask(taskId);
      // Award points to child after task approval (Phase 4 Step M)
      await ref.read(userProvider.notifier).addPoints(childId, points);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Parent rejects task — status → todo
  Future<void> rejectTask(String taskId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.rejectTask(taskId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final taskProvider =
    NotifierProvider<TaskNotifier, TaskState>(() => TaskNotifier());