import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reward_model.dart';
import '../repositories/reward_repository.dart';

class RewardNotifier extends Notifier<List<RewardModel>> {
  final RewardRepository _repo = RewardRepository();

  @override
  List<RewardModel> build() => [];

  void startListening(String familyId) {
    _repo.watchRewards(familyId).listen((updated) {
      state = updated;
    });
  }
}

final rewardProvider =
    NotifierProvider<RewardNotifier, List<RewardModel>>(() => RewardNotifier());