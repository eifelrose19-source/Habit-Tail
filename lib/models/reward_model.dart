import 'package:cloud_firestore/cloud_firestore.dart';

class RewardModel {
  final String rewardId;
  final String createdBy;
  final String familyId;
  final String description; 
  final bool isActive;
  final bool isAvailable;
  final int cost; 
  final String title;
  final DateTime timestamp;

  RewardModel({
    required this.rewardId,
    required this.createdBy,
    required this.familyId,
    required this.description,
    required this.isActive,
    required this.isAvailable,
    required this.cost,
    required this.title,
    required this.timestamp,
  });

  factory RewardModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    return RewardModel(
      rewardId: doc.id,
      createdBy: data['created_by'] ?? "",
      // FIX: Changed 'family_id:' to 'familyId:' to match your constructor
      familyId: data['family_id'] ?? "",
      description: data['description'] ?? "",
      isActive: data['is_active'] ?? false,
      isAvailable: data['is_available'] ?? false,
      cost: (data['cost'] as num?)?.toInt() ?? 0,
      title: data['title'] ?? "",
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'created_by': createdBy,
      'family_id': familyId,
      'description': description,
      'is_active': isActive,
      'is_available': isAvailable,
      'cost': cost,
      'title': title,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  RewardModel copyWith({
    String? rewardId,
    String? createdBy,
    String? familyId,
    String? description,
    bool? isActive,
    bool? isAvailable,
    int? cost,
    String? title,
    DateTime? timestamp,
  }) {
    return RewardModel(
      rewardId: rewardId ?? this.rewardId,
      createdBy: createdBy ?? this.createdBy,
      familyId: familyId ?? this.familyId,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      cost: cost ?? this.cost,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RewardModel && other.rewardId == rewardId;
  }

  @override
  int get hashCode => rewardId.hashCode;

  @override
  String toString() => 'Reward(title: $title, cost: $cost)';
}