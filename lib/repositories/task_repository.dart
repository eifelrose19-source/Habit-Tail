import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskRepository {
  final TaskService _service = TaskService();

  Stream<List<TaskModel>> watchTasks(String familyId) {
    return _service.getTaskStream(familyId).map((snapshot) {
      return snapshot.docs.map((doc) => 
        TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)
      ).toList();
    });
  }
}