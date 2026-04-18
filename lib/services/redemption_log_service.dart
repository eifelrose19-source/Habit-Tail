import '../models/redemption_log_model.dart';
import '../repositories/redemption_log_repository.dart';
import '../repositories/user_repository.dart';

class RedemptionLogService {
  final RedemptionLogRepository _repository = RedemptionLogRepository();
  final UserRepository _userRepository = UserRepository();

  Stream<List<RedemptionLogModel>> watchRedemptionLogs(String familyId) {
    return _repository.watchRedemptionLogs(familyId);
  }

  Future<void> approveRedemption(String logId) async {
    await _repository.updateRedemptionLog(logId, {'status': 'approved'});
  }

  Future<void> rejectRedemption(String logId) async {
    final log = await _repository.getRedemptionLog(logId);
    if (log == null) throw Exception('Redemption log not found.');
    await _userRepository.addPoints(log.childId, log.cost);
    await _repository.updateRedemptionLog(logId, {'status': 'rejected'});
  }
}