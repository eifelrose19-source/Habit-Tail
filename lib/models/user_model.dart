import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String childId;
  final String familyId;
  final String name;
  final String parentId;
  final int totalPoints;

  UserModel({
    required this.userId,
    required this.childId,
    required this.familyId,
    required this.name,
    required this.parentId,
    required this.totalPoints,
  });

  /// Factory constructor using DocumentSnapshot to handle ID and data at once
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return UserModel(
      userId: doc.id,
      childId: data['Child_id'] ?? "",
      familyId: data['Family_id'] ?? "",
      name: data['Name'] ?? "",
      parentId: data['Parent_id'] ?? "",
      totalPoints: (data['Total_points'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts model to Map for Firestore using your specific PascalCase keys
  Map<String, dynamic> toFirestore() {
    return {
      'Child_id': childId,
      'Family_id': familyId,
      'Name': name,
      'Parent_id': parentId,
      'Total_points': totalPoints,
    };
  }

  /// Returns a new instance with updated fields for easier state management
  UserModel copyWith({
    String? userId,
    String? childId,
    String? familyId,
    String? name,
    String? parentId,
    int? totalPoints,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      childId: childId ?? this.childId,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.userId == userId &&
        other.childId == childId &&
        other.familyId == familyId &&
        other.name == name &&
        other.parentId == parentId &&
        other.totalPoints == totalPoints;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      childId,
      familyId,
      name,
      parentId,
      totalPoints,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, childId: $childId, familyId: $familyId, name: $name, parentId: $parentId, totalPoints: $totalPoints)';
  }
}