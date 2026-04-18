import '../models/redemption_log_model.dart';
import '../repositories/redemption_log_repository.dart';
import '../repositories/user_repository.dart';

class RedemptionLogService {
  final RedemptionLogRepository _repository = RedemptionLogRepository();
  final UserRepository _userRepository = UserRepository();

  /// Streams all redemption logs for a family
  Stream<List<RedemptionLogModel>> watchRedemptionLogs(String familyId) {
    return _repository.watchRedemptionLogs(familyId);
  }

  /// Parent approves redemption — marks as delivered (Phase 4 Step P)
  Future<void> approveRedemption(String logId) async {
    await _repository.updateRedemptionLog(logId, {'status': 'approved'});
  }

  /// Parent rejects redemption — refunds points to child
  Future<void> rejectRedemption(String logId) async {
    final log = await _repository.getRedemptionLog(logId);
    if (log == null) throw Exception('Redemption log not found.');

    // Refund points since they were deducted at submission
    await _userRepository.addPoints(log.childId, log.cost);
    await _repository.updateRedemptionLog(logId, {'status': 'rejected'});
  }
}