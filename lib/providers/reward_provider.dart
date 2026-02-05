import 'package:flutter/material.dart';
import '../models/reward_model.dart';
import '../repositories/reward_repository.dart';

class RewardProvider with ChangeNotifier {
  final RewardRepository _repo = RewardRepository();
  List<RewardModel> _rewards = [];

  List<RewardModel> get rewards => _rewards;

  void startListening(String familyId) {
    _repo.watchRewards(familyId).listen((updatedRewards) {
      _rewards = updatedRewards;
      notifyListeners();
    });
  }
}