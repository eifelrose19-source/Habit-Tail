import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String familyID;
  final String name;
  final int totalPoints;
  final String? parentId; // Made nullable
  final String? childId;  // Made nullable

  UserModel({
    required this.uid,
    required this.familyID,
    required this.name,
    required this.totalPoints,
    this.parentId,
    this.childId,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      familyID: data['family_id'] ?? "",
      name: data['name'] ?? 'New Member',
      totalPoints: data['total_points'] ?? 0,
      parentId: data['parent_id'],
      childId: data['child_id'],
    );
  }

  // Simplified logic: If they have a parentId, they are a child.
  bool get isChild => parentId != null;
  bool get isParent => parentId == null;
}

class TaskModel {
  final String id;
  final String title;
  final int points;
  final String frequency;
  final DateTime? lastCompleted;
  final String createdBy;

  TaskModel({
    required this.id,
    required this.title,
    required this.points,
    required this.frequency,
    this.lastCompleted,
    required this.createdBy,
  });

  factory TaskModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TaskModel(
      id: id,
      title: data['title'] ?? 'New Task',
      points: data['points'] ?? 0,
      frequency: data['frequency'] ?? 'Daily',
      lastCompleted: data['last_completed'] != null
          ? (data['last_completed'] as Timestamp).toDate()
          : null,
      createdBy: data['created_by'] ?? "",
    );
  }
}