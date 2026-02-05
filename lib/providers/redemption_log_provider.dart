import 'package:flutter/material.dart';
import '../models/redemption_log_model.dart';
import '../repositories/redemption_log_repository.dart';

class RedemptionLogProvider with ChangeNotifier {
  final RedemptionLogRepository _repo = RedemptionLogRepository();
  List<RedemptionLogModel> _logs = [];

  List<RedemptionLogModel> get logs => _logs;

  void startListening(String familyId) {
    _repo.watchRedemptionLogs(familyId).listen((updatedLogs) {
      _logs = updatedLogs;
      notifyListeners();
    });
  }
}