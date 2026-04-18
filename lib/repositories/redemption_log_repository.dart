import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/redemption_log_model.dart';

class RedemptionLogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<RedemptionLogModel?> getRedemptionLog(String logId) async {
    final doc = await _firestore.collection('redemption_log').doc(logId).get();
    if (!doc.exists) return null;
    return RedemptionLogModel.fromFirestore(doc);
  }

  Future<void> createRedemptionLog(RedemptionLogModel log) async {
    await _firestore.collection('redemption_log').add(log.toFirestore());
  }

  Future<void> updateRedemptionLog(String logId, Map<String, dynamic> data) async {
    await _firestore.collection('redemption_log').doc(logId).update(data);
  }

  Future<void> deleteRedemptionLog(String logId) async {
    await _firestore.collection('redemption_log').doc(logId).delete();
  }
}