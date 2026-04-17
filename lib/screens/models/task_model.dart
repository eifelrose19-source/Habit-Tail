import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskId;
  final String assignedTo;
  final String createdBy;
  final String familyId;
  final String frequency;
  final int points;
  final String status;
  final String title;

  TaskModel({
    required this.taskId,
    required this.assignedTo,
    required this.createdBy,
    required this.familyId,
    required this.frequency,
    required this.points,
    required this.status,
    required this.title,
  });

  // Factory constructor to create a TaskModel from Firestore document
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      taskId: doc.id,
      assignedTo: data['assigned_to'] ?? '',
      createdBy: data['created_by'] ?? '',
      familyId: data['family_id'] ?? '',
      frequency: data['frequency'] ?? 'Daily',
      points: data['points'] ?? 0,
      status: data['status'] ?? 'active',
      title: data['title'] ?? '',
    );
  }

  // Method to convert TaskModel to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'assigned_to': assignedTo,
      'created_by': createdBy,
      'family_id': familyId,
      'frequency': frequency,
      'points': points,
      'status': status,
      'title': title,
    };
  }

  // CopyWith method for easy updating of specific fields
  TaskModel copyWith({
    String? taskId,
    String? assignedTo,
    String? createdBy,
    String? familyId,
    String? frequency,
    int? points,
    String? status,
    String? title,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      familyId: familyId ?? this.familyId,
      frequency: frequency ?? this.frequency,
      points: points ?? this.points,
      status: status ?? this.status,
      title: title ?? this.title,
    );
  }
}