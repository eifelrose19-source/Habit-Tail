import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskId;
  final List<String> assignedTo; 
  final String createdBy;
  final String familyId;
  final String frequency;
  final int points;
  final String title;
  final String status;
  final DateTime? lastCompleted;
  final String petId;

  TaskModel({
    required this.taskId,
    required this.assignedTo,
    required this.createdBy,
    required this.familyId,
    required this.frequency,
    required this.points,
    required this.title,
    required this.status,
    required this.petId,
    this.lastCompleted,
  });

  /// Factory constructor
  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return TaskModel(
      taskId: doc.id,
      assignedTo: List<String>.from(data['assigned_to'] ?? []),
      createdBy: data['created_by'] ?? "",
      familyId: data['family_id'] ?? "",
      frequency: data['frequency'] ?? "",
      points: (data['points'] as num?)?.toInt() ?? 0,
      title: data['title'] ?? "",
      status: data['status'] ?? "todo",
      petId: data['pet_id'] ?? "",
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
      'pet_id': petId,
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
    List<String>? assignedTo,
    String? createdBy,
    String? familyId,
    String? frequency,
    String? petId,
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
      petId: petId ?? this.petId,
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

