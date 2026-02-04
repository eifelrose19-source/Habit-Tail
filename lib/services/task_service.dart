import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getTaskStream(String familyId) {
    return _db.collection('Families').doc(familyId).collection('Tasks').snapshots();
  }

  Future<void> updateTaskStatus(String familyId, String taskId, Map<String, dynamic> data) {
    return _db.collection('Families').doc(familyId).collection('Tasks').doc(taskId).update(data);
  }
}