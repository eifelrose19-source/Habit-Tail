
import '../models/redemption_log_model.dart';
import '../repositories/redemption_log_repository.dart';

class RedemptionService {
  final RedemptionLogRepository _repository = RedemptionLogRepository();

  Stream<List<RedemptionLogModel>> getRedemptionLogs(String familyId) {
    return _repository.watchRedemptionLogs(familyId);
  }

  Future<RedemptionLogModel?> getRedemptionLogById(
      String familyId, String logId) async {
    return await _repository.getRedemptionLog(familyId, logId);
  }

  Future<void> addRedemptionLog(
      String familyId, RedemptionLogModel log) async {
    await _repository.createRedemptionLog(familyId, log);
  }

  Future<void> updateRedemptionLog(
      String familyId, String logId, Map<String, dynamic> data) async {
    await _repository.updateRedemptionLog(familyId, logId, data);
  }

  Future<void> deleteRedemptionLog(String familyId, String logId) async {
    await _repository.deleteRedemptionLog(familyId, logId);
  }

  // Helper method to create a redemption log
  Future<void> redeemReward({
    required String familyId,
    required String claimedBy,
    required String rewardId,
    String status = 'Pending Approval',
  }) async {
    final log = RedemptionLogModel(
      logId: '', // Firestore will auto-generate this
      claimedBy: claimedBy,
      rewardTimestamp: DateTime.now(),
      rewardId: rewardId,
      status: status,
    );
    await _repository.createRedemptionLog(familyId, log);
  }

  // Helper method to approve a redemption
  Future<void> approveRedemption(String familyId, String logId) async {
    await _repository.updateRedemptionLog(
      familyId,
      logId,
      {'Status': 'Approved'},
    );
  }

  // Helper method to reject a redemption
  Future<void> rejectRedemption(String familyId, String logId) async {
    await _repository.updateRedemptionLog(
      familyId,
      logId,
      {'Status': 'Rejected'},
    );
  }
}