import 'package:cloud_firestore/cloud_firestore.dart';

class RewardModel {
  final String rewardId;
  final String createdBy;
  final String familyId;
  final bool isActive;
  final bool isAvailable;
  final String rewardPrice; // or int if it's a number
  final String rewardTitle;
  final DateTime timestampCreated;

  RewardModel({
    required this.rewardId,
    required this.createdBy,
    required this.familyId,
    required this.isActive,
    required this.isAvailable,
    required this.rewardPrice,
    required this.rewardTitle,
    required this.timestampCreated,
  });

  factory RewardModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    return RewardModel(
      rewardId: doc.id,
      createdBy: data['Created_by'] ?? "",
      familyId: data['Family_id'] ?? "",
      isActive: data['Is_active'] ?? false,
      isAvailable: data['Is_available'] ?? false,
      rewardPrice: data['Reward_price'] ?? "",
      rewardTitle: data['Reward_title'] ?? "",
      timestampCreated: (data['Timestamp_created'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'Created_by': createdBy,
      'Family_id': familyId,
      'Is_active': isActive,
      'Is_available': isAvailable,
      'Reward_price': rewardPrice,
      'Reward_title': rewardTitle,
      'Timestamp_created': Timestamp.fromDate(timestampCreated),
    };
  }

  RewardModel copyWith({
    String? rewardId,
    String? createdBy,
    String? familyId,
    bool? isActive,
    bool? isAvailable,
    String? rewardPrice,
    String? rewardTitle,
    DateTime? timestampCreated,
  }) {
    return RewardModel(
      rewardId: rewardId ?? this.rewardId,
      createdBy: createdBy ?? this.createdBy,
      familyId: familyId ?? this.familyId,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      rewardPrice: rewardPrice ?? this.rewardPrice,
      rewardTitle: rewardTitle ?? this.rewardTitle,
      timestampCreated: timestampCreated ?? this.timestampCreated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is RewardModel &&
        other.rewardId == rewardId &&
        other.createdBy == createdBy &&
        other.familyId == familyId &&
        other.isActive == isActive &&
        other.isAvailable == isAvailable &&
        other.rewardPrice == rewardPrice &&
        other.rewardTitle == rewardTitle &&
        other.timestampCreated == timestampCreated;
  }

  @override
  int get hashCode {
    return Object.hash(
      rewardId,
      createdBy,
      familyId,
      isActive,
      isAvailable,
      rewardPrice,
      rewardTitle,
      timestampCreated,
    );
  }

  @override
  String toString() {
    return 'RewardModel(rewardId: $rewardId, createdBy: $createdBy, familyId: $familyId, isActive: $isActive, isAvailable: $isAvailable, rewardPrice: $rewardPrice, rewardTitle: $rewardTitle, timestampCreated: $timestampCreated)';
  }
}