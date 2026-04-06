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
  final bool claimed;
  final String? parentalPin;

  UserModel({
    required this.userId,
    required this.familyId,
    required this.name,
    required this.totalPoints,
    required this.isParent,
    this.claimed = false,
    this.parentId,
    this.childrenIds = const [],
    this.parentalPin,
  });

  // --- UI Bridge Getters ---
  // These allow the UI to call .displayName and .role without errors
  String get displayName => name;
  String get role => isParent ? 'parent' : 'child';

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return UserModel(
      userId: doc.id,
      familyId: data['family_id'] ?? "",
      name: data['display_name'] ?? "",
      totalPoints: (data['total_points'] as num?)?.toInt() ?? 0,
      isParent: data['role'] == 'parent',
      parentId: data['parent_id'],
      claimed: data['claimed'] ?? false,
      parentalPin: data['parentalPin'],
      childrenIds: List<String>.from(data['children_id'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'family_id': familyId,
      'display_name': name,
      'total_points': totalPoints,
      'role': isParent ? 'parent' : 'child',
      'claimed': claimed,
      if (parentId != null) 'parent_id': parentId,
      if (parentalPin != null) 'parentalPin': parentalPin,
      'children_id': childrenIds,
    };
  }

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
    bool? claimed,
    String? parentalPin,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      totalPoints: totalPoints ?? this.totalPoints,
      isParent: isParent ?? this.isParent,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
      claimed: claimed ?? this.claimed,
      parentalPin: parentalPin ?? this.parentalPin,
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
      'UserModel(name: $name, isParent: $isParent, points: $totalPoints, claimed: $claimed)';
}