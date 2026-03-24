import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reward_model.dart';

class RewardNotifier extends Notifier<List<RewardModel>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  List<RewardModel> build() {
    ref.onDispose(() => _subscription?.cancel());
    return [];
  }

  /// Listens to all rewards available for a specific family
  void watchFamilyRewards(String familyId) {
    _subscription?.cancel();

    _subscription = _firestore
        .collection('rewards')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs
          .map((doc) => RewardModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Toggles whether a reward is active/visible to children
  Future<void> toggleRewardStatus(String rewardId, bool isActive) async {
    await _firestore
        .collection('rewards')
        .doc(rewardId)
        .update({'is_active': isActive});
  }
}

final rewardProvider =
    NotifierProvider<RewardNotifier, List<RewardModel>>(() => RewardNotifier());