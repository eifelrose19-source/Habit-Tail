import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/redemption_log_model.dart';
import '../services/redemption_log_service.dart';
import 'user_provider.dart';

final redemptionLogServiceProvider =
    Provider<RedemptionLogService>((ref) => RedemptionLogService());

// Live stream of all redemption logs for a family
final familyRedemptionLogsProvider =
    StreamProvider<List<RedemptionLogModel>>((ref) {
  final familyId = ref.watch(userProvider).user?.familyId ?? '';
  if (familyId.isEmpty) return const Stream.empty();
  return ref
      .read(redemptionLogServiceProvider)
      .watchRedemptionLogs(familyId);
});

class RedemptionLogState {
  final bool isLoading;
  final String? error;

  const RedemptionLogState({
    this.isLoading = false,
    this.error,
  });

  RedemptionLogState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      RedemptionLogState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class RedemptionLogNotifier extends Notifier<RedemptionLogState> {
  late final RedemptionLogService _service;

  @override
  RedemptionLogState build() {
    _service = ref.read(redemptionLogServiceProvider);
    return const RedemptionLogState();
  }

  /// Parent approves redemption — marks as delivered
  Future<void> approveRedemption(String logId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.approveRedemption(logId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Parent rejects redemption — refunds points to child
  Future<void> rejectRedemption(String logId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.rejectRedemption(logId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final redemptionLogProvider =
    NotifierProvider<RedemptionLogNotifier, RedemptionLogState>(
        () => RedemptionLogNotifier());