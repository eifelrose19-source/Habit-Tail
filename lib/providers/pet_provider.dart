import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../services/pet_service.dart';
import 'user_provider.dart';

final petServiceProvider = Provider<PetService>((ref) => PetService());

// Live stream of all family pets — used by pet screen
final familyPetsProvider = StreamProvider<List<PetModel>>((ref) {
  final familyId = ref.watch(userProvider).user?.familyId ?? '';
  if (familyId.isEmpty) return const Stream.empty();
  return ref.read(petServiceProvider).watchFamilyPets(familyId);
});

class PetState {
  final bool isLoading;
  final String? error;

  const PetState({
    this.isLoading = false,
    this.error,
  });

  PetState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      PetState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class PetNotifier extends Notifier<PetState> {
  late final PetService _service;

  @override
  PetState build() {
    _service = ref.read(petServiceProvider);
    return const PetState();
  }

  /// Parent adds a new pet to the family
  Future<void> createPet(PetModel pet) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.createPet(pet);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Parent updates pet info
  Future<void> updatePet(String petId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.updatePet(petId, data);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Parent deletes pet and all linked tasks
  Future<void> deletePet(String petId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.deletePet(petId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final petProvider =
    NotifierProvider<PetNotifier, PetState>(() => PetNotifier());