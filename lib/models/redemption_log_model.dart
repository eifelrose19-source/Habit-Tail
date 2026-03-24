import 'package:cloud_firestore/cloud_firestore.dart';

class RedemptionLogModel {
  final String logId;
  final String childId;
  final String parentId;
  final String familyId;
  final String rewardId;
  final String status;
  final int cost;
  final DateTime timestamp;

  RedemptionLogModel({
    required this.logId,
    required this.childId,
    required this.parentId,
    required this.familyId,
    required this.rewardId,
    required this.status,
    required this.cost,
    required this.timestamp,
  });

  factory RedemptionLogModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    return RedemptionLogModel(
      logId: doc.id,
      childId: data['child_id'] ?? "",
      parentId: data['parent_id'] ?? "",
      familyId: data['family_id'] ?? "",
      rewardId: data['reward_id'] ?? "",
      status: data['status'] ?? "pending",
      cost: (data['cost'] as num?)?.toInt() ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts model to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'child_id': childId,
      'parent_id': parentId,
      'family_id': familyId,
      'reward_id': rewardId,
      'status': status,
      'cost': cost,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// CopyWith for Riverpod state updates (e.g., changing status to 'approved')
  RedemptionLogModel copyWith({
    String? logId,
    String? childId,
    String? parentId,
    String? familyId,
    String? rewardId,
    String? status,
    int? cost,
    DateTime? timestamp,
  }) {
    return RedemptionLogModel(
      logId: logId ?? this.logId,
      childId: childId ?? this.childId,
      parentId: parentId ?? this.parentId,
      familyId: familyId ?? this.familyId,
      rewardId: rewardId ?? this.rewardId,
      status: status ?? this.status,
      cost: cost ?? this.cost,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RedemptionLogModel && other.logId == logId;
  }

  @override
  int get hashCode => logId.hashCode;

  @override
  String toString() => 'RedemptionLog(rewardId: $rewardId, status: $status)';
}