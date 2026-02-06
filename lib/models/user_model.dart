import 'package:cloud_firestore/cloud_firestore.dart';

enum DashboardType { parent, child }

class UserModel {
  final String userId;
  final String familyId;
  final String name;
  final int totalPoints;
  final bool isParent;

  UserModel({
    required this.userId,
    required this.familyId,
    required this.name,
    required this.totalPoints,
    required this.isParent,
  });

  /// Factory constructor using DocumentSnapshot to handle ID and data at once
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return UserModel(
      userId: doc.id,
      familyId: data['Family_id'] ?? "",
      name: data['Name'] ?? "",
      totalPoints: (data['Total_points'] as num?)?.toInt() ?? 0,
      isParent: data['Is_parent'] ?? false, // Add this field
    );
  }

  /// Converts model to Map for Firestore using HabitTail specific PascalCase keys
  Map<String, dynamic> toFirestore() {
    return {
      'Family_id': familyId,
      'Name': name,
      'Total_points': totalPoints,
      'Is_parent': isParent, // Add this field
    };
  }

  /// Getter to determine dashboard type based on role
  DashboardType get dashboardType => isParent ? DashboardType.parent : DashboardType.child;

  /// Returns a new instance with updated fields for easier state management
  UserModel copyWith({
    String? userId,
    String? familyId,
    String? name,
    int? totalPoints,
    bool? isParent,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      totalPoints: totalPoints ?? this.totalPoints,
      isParent: isParent ?? this.isParent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.userId == userId &&
        other.familyId == familyId &&
        other.name == name &&
        other.totalPoints == totalPoints &&
        other.isParent == isParent;
  }

  @override
  int get hashCode {
    return Object.hash(userId, familyId, name, totalPoints, isParent);
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, familyId: $familyId, name: $name, totalPoints: $totalPoints, isParent: $isParent)';
  }
}