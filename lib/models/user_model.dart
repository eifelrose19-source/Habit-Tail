import 'package:cloud_firestore/cloud_firestore.dart';

enum DashboardType { parent, child }

class UserModel {
  final String userId;
  final String familyId;
  final String name;
  final int totalPoints;
  final bool isParent;
  final String? parentId;
  final List<String> childrenIds;

  UserModel({
    required this.userId,
    required this.familyId,
    required this.name,
    required this.totalPoints,
    required this.isParent,
    this.parentId,
    this.childrenIds = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return UserModel(
      userId: doc.id,
      familyId: data['family_id'] ?? "",
      // FIXED: was data['name'] — Firestore field is 'display_name'
      name: data['display_name'] ?? "",
      totalPoints: (data['total_points'] as num?)?.toInt() ?? 0,
      // FIXED: was data['is_parent'] (bool) — Firestore uses role: "parent"/"child" (string)
      isParent: data['role'] == 'parent',
      parentId: data['parent_id'],
      // FIXED: was data['children_ids'] — Firestore field is 'children_id'
      childrenIds: List<String>.from(data['children_id'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'family_id': familyId,
      // FIXED: was 'name' — Firestore field is 'display_name'
      'display_name': name,
      'total_points': totalPoints,
      // FIXED: was 'is_parent': isParent — Firestore uses 'role' string
      'role': isParent ? 'parent' : 'child',
      if (parentId != null) 'parent_id': parentId,
      // FIXED: was 'children_ids' — Firestore field is 'children_id'
      'children_id': childrenIds,
    };
  }

  // UNCHANGED: everything below this line is correct and untouched

  DashboardType get dashboardType =>
      isParent ? DashboardType.parent : DashboardType.child;

  UserModel copyWith({
    String? userId,
    String? familyId,
    String? name,
    int? totalPoints,
    bool? isParent,
    String? parentId,
    List<String>? childrenIds,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      totalPoints: totalPoints ?? this.totalPoints,
      isParent: isParent ?? this.isParent,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() =>
      'UserModel(name: $name, isParent: $isParent, points: $totalPoints)';
}