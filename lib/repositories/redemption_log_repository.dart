import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/redemption_log_model.dart';

class RedemptionLogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<RedemptionLogModel>> watchRedemptionLogs(String familyId) {
    return _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Redemption Logs')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RedemptionLogModel.fromFirestore(doc))
            .toList());
  }

  Future<RedemptionLogModel?> getRedemptionLog(
      String familyId, String logId) async {
    final doc = await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Redemption Logs')
        .doc(logId)
        .get();
    if (!doc.exists) return null;
    return RedemptionLogModel.fromFirestore(doc);
  }

  Future<void> createRedemptionLog(
      String familyId, RedemptionLogModel log) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Redemption Logs')
        .add(log.toFirestore());
  }

  Future<void> updateRedemptionLog(
      String familyId, String logId, Map<String, dynamic> data) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Redemption Logs')
        .doc(logId)
        .update(data);
  }

  Future<void> deleteRedemptionLog(String familyId, String logId) async {
    await _firestore
        .collection('Families')
        .doc(familyId)
        .collection('Redemption Logs')
        .doc(logId)
        .delete();
  }
}