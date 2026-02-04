import 'package:cloud_firestore/cloud_firestore.dart';

class RedemptionLogModel {
  final String logId;
  final String claimedBy;
  final DateTime rewardTimestamp;
  final String rewardId;
  final String status;

  RedemptionLogModel({
    required this.logId,
    required this.claimedBy,
    required this.rewardTimestamp,
    required this.rewardId,
    required this.status,
  });

  factory RedemptionLogModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    return RedemptionLogModel(
      logId: doc.id,
      claimedBy: data['Claimed_by'] ?? "",
      rewardTimestamp: (data['Reward_Timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rewardId: data['Reward_id'] ?? "",
      status: data['Status'] ?? "",
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'Claimed_by': claimedBy,
      'Reward_Timestamp': Timestamp.fromDate(rewardTimestamp),
      'Reward_id': rewardId,
      'Status': status,
    };
  }

  RedemptionLogModel copyWith({
    String? logId,
    String? claimedBy,
    DateTime? rewardTimestamp,
    String? rewardId,
    String? status,
  }) {
    return RedemptionLogModel(
      logId: logId ?? this.logId,
      claimedBy: claimedBy ?? this.claimedBy,
      rewardTimestamp: rewardTimestamp ?? this.rewardTimestamp,
      rewardId: rewardId ?? this.rewardId,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is RedemptionLogModel &&
        other.logId == logId &&
        other.claimedBy == claimedBy &&
        other.rewardTimestamp == rewardTimestamp &&
        other.rewardId == rewardId &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(logId, claimedBy, rewardTimestamp, rewardId, status);
  }

  @override
  String toString() {
    return 'RedemptionLogModel(logId: $logId, claimedBy: $claimedBy, rewardTimestamp: $rewardTimestamp, rewardId: $rewardId, status: $status)';
  }
}