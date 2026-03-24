import 'package:cloud_firestore/cloud_firestore.dart';

enum DashboardType { parent, child }

class UserModel {
  final String userId;
  final String familyId;
  final String name;
  final int totalPoints;
  final bool isParent;
  final String? parentId; // Added for child link
  final List<String> childrenIds; // Added for parent link

  UserModel({
    required this.userId,
    required this.familyId,
    required this.name,
    required this.totalPoints,
    required this.isParent,
    this.parentId,
    this.childrenIds = const [],
  });

  /// Factory constructor 
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return UserModel(
      userId: doc.id,
      familyId: data['family_id'] ?? "",
      name: data['name'] ?? "",
      totalPoints: (data['total_points'] as num?)?.toInt() ?? 0,
      isParent: data['is_parent'] ?? false,
      parentId: data['parent_id'],
      childrenIds: List<String>.from(data['children_ids'] ?? []),
    );
  }

  /// Converts model to Map for Firestore 
  Map<String, dynamic> toFirestore() {
    return {
      'family_id': familyId,
      'name': name,
      'total_points': totalPoints,
      'is_parent': isParent,
      if (parentId != null) 'parent_id': parentId,
      'children_ids': childrenIds,
    };
  }

  /// Getter to determine dashboard type based on role
  DashboardType get dashboardType => isParent ? DashboardType.parent : DashboardType.child;

  /// Returns a new instance with updated fields for Riverpod state management
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
  String toString() {
    return 'UserModel(name: $name, isParent: $isParent, points: $totalPoints)';
  }
}

