import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/redemption_log_model.dart';

class RedemptionLogNotifier extends Notifier<List<RedemptionLogModel>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  List<RedemptionLogModel> build() {
    ref.onDispose(() => _subscription?.cancel());
    return [];
  }

  /// Listens to redemption requests for a specific family
  void watchFamilyRedemptions(String familyId) {
    _subscription?.cancel();

    _subscription = _firestore
        .collection('redemption_log')
        .where('family_id', isEqualTo: familyId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs
          .map((doc) => RedemptionLogModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Updates the status of a redemption request (e.g., 'approved' or 'denied')
  Future<void> updateRedemptionStatus(String logId, String newStatus) async {
    await _firestore
        .collection('redemption_log')
        .doc(logId)
        .update({'status': newStatus});
  }
}

final redemptionLogProvider =
    NotifierProvider<RedemptionLogNotifier, List<RedemptionLogModel>>(
        () => RedemptionLogNotifier());