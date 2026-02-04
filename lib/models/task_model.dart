import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String taskId;
  final String createdBy;
  final String familyId;
  final String frequency;
  final int points;
  final String title;
  final DateTime? lastCompleted;

  TaskModel({
    required this.taskId,
    required this.createdBy,
    required this.familyId,
    required this.frequency,
    required this.points,
    required this.title,
    this.lastCompleted,
  });

  /// Factory constructor using DocumentSnapshot to handle ID and data at once
  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return TaskModel(
      taskId: doc.id,
      createdBy: data['Created_by'] ?? "",
      familyId: data['Family_id'] ?? "",
      frequency: data['Frequency'] ?? "",
      points: (data['Points'] as num?)?.toInt() ?? 0,
      title: data['Title'] ?? "",
      lastCompleted: (data['last_completed'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts model to Map for Firestore using your specific keys
  Map<String, dynamic> toFirestore() {
    return {
      'Created_by': createdBy,
      'Family_id': familyId,
      'Frequency': frequency,
      'Points': points,
      'Title': title,
      'last_completed': lastCompleted != null ? Timestamp.fromDate(lastCompleted!) : null,
    };
  }

  /// Returns a new instance with updated fields for easier state management
  TaskModel copyWith({
    String? taskId,
    String? createdBy,
    String? familyId,
    String? frequency,
    int? points,
    String? title,
    DateTime? lastCompleted,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      createdBy: createdBy ?? this.createdBy,
      familyId: familyId ?? this.familyId,
      frequency: frequency ?? this.frequency,
      points: points ?? this.points,
      title: title ?? this.title,
      lastCompleted: lastCompleted ?? this.lastCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskModel &&
        other.taskId == taskId &&
        other.createdBy == createdBy &&
        other.familyId == familyId &&
        other.frequency == frequency &&
        other.points == points &&
        other.title == title &&
        other.lastCompleted == lastCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      taskId,
      createdBy,
      familyId,
      frequency,
      points,
      title,
      lastCompleted,
    );
  }

  @override
  String toString() {
    return 'TaskModel(taskId: $taskId, createdBy: $createdBy, familyId: $familyId, frequency: $frequency, points: $points, title: $title, lastCompleted: $lastCompleted)';
  }

  /// Compatibility factory used by older repositories expecting `fromMap`
  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      taskId: id,
      createdBy: map['Created_by'] ?? "",
      familyId: map['Family_id'] ?? "",
      frequency: map['Frequency'] ?? "",
      points: (map['Points'] is num) ? (map['Points'] as num).toInt() : 0,
      title: map['Title'] ?? map['title'] ?? "",
      lastCompleted: map['last_completed'] is Timestamp ? (map['last_completed'] as Timestamp).toDate() : null,
    );
  }
}

extension TaskModelCompat on TaskModel {
  String get id => taskId;

  Map<String, dynamic> toMap() => toFirestore();
}