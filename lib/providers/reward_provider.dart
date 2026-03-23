import 'dart:async';
import 'package:flutter/material.dart';
import '../models/reward_model.dart';
import '../repositories/reward_repository.dart';
import 'dart:developer' as developer;

class RewardProvider with ChangeNotifier {
  final RewardRepository _repo = RewardRepository();
  StreamSubscription<List<RewardModel>>? _subscription;
  List<RewardModel> _rewards = [];

  List<RewardModel> get rewards => _rewards;

  void startListening(String familyId) {
    _subscription?.cancel();
    _subscription = _repo.watchRewards(familyId).listen(
      (updatedRewards) {
        _rewards = updatedRewards;
        notifyListeners();
      },
      onError: (error) {
        developer.log('RewardProvider stream error: $error',
            name: 'RewardProvider');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
