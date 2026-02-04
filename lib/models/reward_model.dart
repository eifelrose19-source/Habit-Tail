import 'package:cloud_firestore/cloud_firestore.dart';

class RewardModel {
  final String rewardId; // Document ID
  final String claimedBy;
  final DateTime rewardTimestamp;
  final String status;

  RewardModel({
    required this.rewardId,
    required this.claimedBy,
    required this.rewardTimestamp,
    required this.status,
  });

  /// Factory constructor using DocumentSnapshot to handle ID and data at once
  factory RewardModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return RewardModel(
      rewardId: doc.id,
      claimedBy: data['Claimed_by'] ?? "",
      // Safely converts Firestore Timestamp to Dart DateTime
      rewardTimestamp:
          (data['Reward_Timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['Status'] ?? "",
    );
  }

  /// Converts model to Map for Firestore using your specific PascalCase keys
  Map<String, dynamic> toFirestore() {
    return {
      'Claimed_by': claimedBy,
      'Reward_Timestamp': Timestamp.fromDate(rewardTimestamp),
      'Status': status,
    };
  }

  /// Returns a new instance with updated fields for easier state management
  RewardModel copyWith({
    String? rewardId,
    String? claimedBy,
    DateTime? rewardTimestamp,
    String? status,
  }) {
    return RewardModel(
      rewardId: rewardId ?? this.rewardId,
      claimedBy: claimedBy ?? this.claimedBy,
      rewardTimestamp: rewardTimestamp ?? this.rewardTimestamp,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RewardModel &&
        other.rewardId == rewardId &&
        other.claimedBy == claimedBy &&
        other.rewardTimestamp == rewardTimestamp &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(rewardId, claimedBy, rewardTimestamp, status);
  }

  @override
  String toString() {
    return 'RewardModel(rewardId: $rewardId, claimedBy: $claimedBy, rewardTimestamp: $rewardTimestamp, status: $status)';
  }
}
