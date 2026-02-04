import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Import for listEquals

class FamilyModel {
  final String familyId;
  final String adminUid;
  final DateTime? createdAt;
  final String subscriptionLevel;
  final List<String> memberIds;

  FamilyModel({
    required this.familyId,
    required this.adminUid,
    this.createdAt,
    required this.subscriptionLevel,
    this.memberIds = const [],
  });

  /// Factory constructor using DocumentSnapshot with PascalCase database keys
  /// Updated to use generic DocumentSnapshot to support various Firestore types
  factory FamilyModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return FamilyModel(
      familyId: doc.id,
      adminUid: data['Admin_uid'] ?? '',
      // Safely converts Firestore Timestamp to Dart DateTime
      createdAt: (data['Created_at'] as Timestamp?)?.toDate(),
      subscriptionLevel: data['Subscription_level'] ?? 'free',
      memberIds: List<String>.from(data['member_ids'] ?? []),
    );
  }

  /// Converts model to Map for Firestore using your specific PascalCase keys
  Map<String, dynamic> toFirestore() {
    return {
      'Admin_uid': adminUid,
      'Family_id': familyId, 
      'Created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'Subscription_level': subscriptionLevel,
      'member_ids': memberIds,
    };
  }

  /// Returns a new instance with updated fields for easier state management
  FamilyModel copyWith({
    String? familyId,
    String? adminUid,
    DateTime? createdAt,
    String? subscriptionLevel,
    List<String>? memberIds,
  }) {
    return FamilyModel(
      familyId: familyId ?? this.familyId,
      adminUid: adminUid ?? this.adminUid,
      createdAt: createdAt ?? this.createdAt,
      subscriptionLevel: subscriptionLevel ?? this.subscriptionLevel,
      memberIds: memberIds ?? this.memberIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is FamilyModel &&
        other.familyId == familyId &&
        other.adminUid == adminUid &&
        other.createdAt == createdAt &&
        other.subscriptionLevel == subscriptionLevel &&
        listEquals(other.memberIds, memberIds);
  }

  @override
  int get hashCode {
    // Using Object.hash for better distribution than the ^ operator
    return Object.hash(
      familyId,
      adminUid,
      createdAt,
      subscriptionLevel,
      Object.hashAll(memberIds), // Deep hash for the list
    );
  }

  @override
  String toString() {
    return 'FamilyModel(familyId: $familyId, adminUid: $adminUid, createdAt: $createdAt, subscriptionLevel: $subscriptionLevel, memberIds: $memberIds)';
  }
}