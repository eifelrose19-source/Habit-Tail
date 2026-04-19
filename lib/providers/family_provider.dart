import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADDED: was missing
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/user_service.dart';
import 'user_provider.dart';

// Stream of all family members — used by parent dashboard
final familyMembersProvider = StreamProvider<List<UserModel>>((ref) {
  final familyId = ref.watch(userProvider).user?.familyId ?? '';
  if (familyId.isEmpty) return const Stream.empty();
  return ref.read(userRepositoryProvider).watchFamilyMembers(familyId);
});

// Stream of unclaimed slots — used by WhoAreYouScreen
final availableSlotsProvider =
    StreamProvider.family<List<UserModel>, String>((ref, familyId) {
  if (familyId.isEmpty) return const Stream.empty();
  return ref
      .read(userRepositoryProvider)
      .watchFamilyMembers(familyId)
      .map((members) => members.where((m) => !m.claimed).toList());
});

class FamilyState {
  final bool isLoading;
  final String? error;
  final String? familyId;

  const FamilyState({
    this.isLoading = false,
    this.error,
    this.familyId,
  });

  FamilyState copyWith({
    bool? isLoading,
    String? error,
    String? familyId,
    bool clearError = false,
  }) =>
      FamilyState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        familyId: familyId ?? this.familyId,
      );
}

class FamilyNotifier extends Notifier<FamilyState> {
  late final UserRepository _repository;
  late final UserService _userService;

  @override
  FamilyState build() {
    _repository = ref.read(userRepositoryProvider);
    _userService = UserService();
    return const FamilyState();
  }

  /// Creates the family — called from CreateFamilyScreen when User submits.
  Future<void> createFamily({
    required String creatorName,
    required String parentalPin,
    required List<Map<String, dynamic>> memberSlots,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not signed in');

      final familyId = generateFamilyId();

      // Creator's own doc — claimed: true, role: parent from the start
      final creatorDoc = UserModel(
        userId: uid,
        familyId: familyId,
        name: creatorName,
        totalPoints: 0,
        isParent: true,
        claimed: true,
        parentalPin: parentalPin,
      );

      // Build seeded slot docs from form data — no UID, claimed: false
      final slots = <UserModel>[];
      for (final slot in memberSlots) {
        final isPartner = slot['isPartner'] as bool;
        slots.add(UserModel(
          userId: '',
          familyId: familyId,
          name: slot['name'] as String,
          totalPoints: 0,
          isParent: isPartner,
          claimed: false,
          parentalPin: isPartner ? parentalPin : null,
          parentId: isPartner ? null : uid,
        ));
      }

      await _repository.setupFamily(uid, creatorDoc, slots);
      state = state.copyWith(isLoading: false, familyId: familyId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Claims a child slot — no PIN needed.
  Future<void> claimChildSlot(String slotDocId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not signed in');

      await _repository.claimSlot(slotDocId, uid);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Claims a parent slot — verifies PIN first.
  /// Returns true if PIN matched and slot claimed, false if PIN wrong.
  Future<bool> claimParentSlot({
    required String slotDocId,
    required String familyId,
    required String enteredPin,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not signed in');

      final pinMatches =
          await _repository.verifyParentalPin(familyId, enteredPin);

      if (!pinMatches) {
        state = state.copyWith(
          isLoading: false,
          error: 'Incorrect PIN. Please try again.',
        );
        return false;
      }

      await _repository.claimSlot(slotDocId, uid);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Adds a new member slot post-family-creation — called from ManageFamily.
  Future<void> addMember({
    required String name,
    required bool isPartner,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final currentUser = ref.read(userProvider).user;
      if (currentUser == null) throw Exception('Not signed in');

      await _userService.addFamilyMember(
        name: name,
        isPartner: isPartner,
        familyId: currentUser.familyId,
        parentUid: currentUser.userId,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Removes a member — called from ManageFamily.
  Future<void> removeMember(UserModel member) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final currentUser = ref.read(userProvider).user;
      if (currentUser == null) throw Exception('Not signed in');

      await _userService.removeFamilyMember(
        member: member,
        parentUid: currentUser.userId,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Renames a member — called from ManageFamily.
  Future<void> renameMember(String memberId, String newName) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _userService.renameFamilyMember(memberId, newName);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Generates a 6-character alphanumeric family ID client-side.
  String generateFamilyId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      6,
      (i) => chars[(random >> (i * 5)) % chars.length],
    ).join();
  }
  /// Saves pin for User
  Future<void> savePinForUser(String uid, String pin) async {
  state = state.copyWith(isLoading: true, clearError: true);
  try {
    await _repository.updateUser(uid, {'parentalPin': pin});
    state = state.copyWith(isLoading: false);
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}
}


final familyProvider =
    NotifierProvider<FamilyNotifier, FamilyState>(() => FamilyNotifier());