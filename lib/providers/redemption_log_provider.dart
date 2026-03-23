import 'dart:async';
import 'package:flutter/material.dart';
import '../models/redemption_log_model.dart';
import '../repositories/redemption_log_repository.dart';
import 'dart:developer' as developer;

class RedemptionLogProvider with ChangeNotifier {
  final RedemptionLogRepository _repo = RedemptionLogRepository();
  StreamSubscription<List<RedemptionLogModel>>? _subscription;
  List<RedemptionLogModel> _logs = [];

  List<RedemptionLogModel> get logs => _logs;

  void startListening(String familyId) {
    _subscription?.cancel();
    _subscription = _repo.watchRedemptionLog(familyId).listen(
      (updatedLogs) {
        _logs = updatedLogs;
        notifyListeners();
      },
      onError: (error) {
        developer.log('RedemptionLogProvider stream error: $error',
            name: 'RedemptionLogProvider');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
