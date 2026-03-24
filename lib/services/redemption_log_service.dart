import '../models/redemption_log_model.dart';
import '../repositories/redemption_log_repository.dart';

class RedemptionService {
  final RedemptionLogRepository _repository = RedemptionLogRepository();

  /// Streams logs for the family
  Stream<List<RedemptionLogModel>> getRedemptionLogs(String familyId) {
    return _repository.watchRedemptionLogs(familyId);
  }

  /// Fetches a single log using the unique document ID
  Future<RedemptionLogModel?> getRedemptionLogById(String logId) async {
    return await _repository.getRedemptionLog(logId);
  }

  /// Adds a new log to the top-level collection
  Future<void> addRedemptionLog(RedemptionLogModel log) async {
    await _repository.createRedemptionLog(log);
  }

  /// Updates status or details using the doc ID
  Future<void> updateRedemptionLog(String logId, Map<String, dynamic> data) async {
    await _repository.updateRedemptionLog(logId, data);
  }

  /// Deletes a log entry directly
  Future<void> deleteRedemptionLog(String logId) async {
    await _repository.deleteRedemptionLog(logId);
  }

  /// Logic for a child to claim a reward
  Future<void> redeemReward({
    required String familyId,
    required String claimedBy,
    required String rewardId,
    String status = 'pending', 
  }) async {
    final log = RedemptionLogModel(
      logId: '', 
      familyId: familyId, 
      claimedBy: claimedBy,
      rewardTimestamp: DateTime.now(),
      rewardId: rewardId,
      status: status,
    );
    await _repository.createRedemptionLog(log);
  }

  /// Logic for a parent to approve a request
  Future<void> approveRedemption(String logId) async {
    await _repository.updateRedemptionLog(
      logId,
      {'status': 'approved'},
    );
  }

  /// Logic for a parent to reject a request
  Future<void> rejectRedemption(String logId) async {
    await _repository.updateRedemptionLog(
      logId,
      {'status': 'rejected'}, 
    );
  }
}

