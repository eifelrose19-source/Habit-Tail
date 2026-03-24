import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskId;
  final String assignedTo; 
  final String createdBy;
  final String familyId;
  final String frequency;
  final int points;
  final String title;
  final String status;
  final DateTime? lastCompleted;

  TaskModel({
    required this.taskId,
    required this.assignedTo,
    required this.createdBy,
    required this.familyId,
    required this.frequency,
    required this.points,
    required this.title,
    required this.status,
    this.lastCompleted,
  });

  /// Factory constructor
  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return TaskModel(
      taskId: doc.id,
      assignedTo: data['assigned_to'] ?? "",
      createdBy: data['created_by'] ?? "",
      familyId: data['family_id'] ?? "",
      frequency: data['frequency'] ?? "",
      points: (data['points'] as num?)?.toInt() ?? 0,
      title: data['title'] ?? "",
      status: data['status'] ?? "todo",
      lastCompleted: (data['last_completed'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts model to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'assigned_to': assignedTo,
      'created_by': createdBy,
      'family_id': familyId,
      'frequency': frequency,
      'points': points,
      'title': title,
      'status': status,
      'last_completed': lastCompleted != null
          ? Timestamp.fromDate(lastCompleted!)
          : null,
    };
  }

  /// CopyWith for Riverpod state updates (e.g., updating status to 'completed')
  TaskModel copyWith({
    String? taskId,
    String? assignedTo,
    String? createdBy,
    String? familyId,
    String? frequency,
    int? points,
    String? title,
    String? status,
    DateTime? lastCompleted,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      familyId: familyId ?? this.familyId,
      frequency: frequency ?? this.frequency,
      points: points ?? this.points,
      title: title ?? this.title,
      status: status ?? this.status,
      lastCompleted: lastCompleted ?? this.lastCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.taskId == taskId;
  }

  @override
  int get hashCode => taskId.hashCode;

  @override
  String toString() => 'TaskModel(title: $title, status: $status)';
}

