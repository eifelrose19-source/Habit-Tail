import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/redemption_log_model.dart';
import '../repositories/redemption_log_repository.dart';

class RedemptionLogNotifier extends Notifier<List<RedemptionLogModel>> {
  final RedemptionLogRepository _repo = RedemptionLogRepository();

  @override
  List<RedemptionLogModel> build() => [];

  void startListening(String familyId) {
    _repo.watchRedemptionLogs(familyId).listen((updated) {
      state = updated;
    });
  }
}

final redemptionLogProvider = NotifierProvider<RedemptionLogNotifier,
    List<RedemptionLogModel>>(() => RedemptionLogNotifier());