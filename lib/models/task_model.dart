import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String uid;
  final String familyID;
  final String name;
  final int totalPoints;
  final String parentId;
  final String childId; 

  TaskModel({
    required this.uid,
    required this.familyID,
    required this.name,
    required this.totalPoints,
    required this.parentId,
    required this.childId,
  }); 

 
  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return TaskModel.fromMap(doc.id, data);
  }

  factory TaskModel.fromMap(String id, Map<String, dynamic> data) {
    return TaskModel(
      uid: id, 
      name: data['name'] as String? ?? '',
      familyID: data['familyID'] as String? ?? '', 
      totalPoints: (data['totalPoints'] as num?)?.toInt() ?? 0, // Handles both int and double from Firestore
      parentId: data['parentId'] as String? ?? '',
      childId: data['childId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'familyID': familyID,
    'totalPoints': totalPoints,
    'parentId': parentId,
    'childId': childId,
  };
}