import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/redemption_log_model.dart';

class RedemptionLogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Streams logs for the family, filtered by the family_id field
  Stream<List<RedemptionLogModel>> watchRedemptionLogs(String familyId) {
    return _firestore
        .collection('redemption_log')
        .where('family_id', isEqualTo: familyId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RedemptionLogModel.fromFirestore(doc))
            .toList());
  }

  /// Gets a single log by its ID
  Future<RedemptionLogModel?> getRedemptionLog(String logId) async {
    final doc = await _firestore.collection('redemption_log').doc(logId).get();
    if (!doc.exists) return null;
    return RedemptionLogModel.fromFirestore(doc);
  }

  /// Adds a new log to the top-level collection
  Future<void> createRedemptionLog(RedemptionLogModel log) async {
    await _firestore
        .collection('redemption_log')
        .add(log.toFirestore());
  }

  /// Updates status or other fields using the doc ID directly
  Future<void> updateRedemptionLog(String logId, Map<String, dynamic> data) async {
    await _firestore
        .collection('redemption_log')
        .doc(logId)
        .update(data);
  }

  /// Deletes a log entry
  Future<void> deleteRedemptionLog(String logId) async {
    await _firestore.collection('redemption_log').doc(logId).delete();
  }
}