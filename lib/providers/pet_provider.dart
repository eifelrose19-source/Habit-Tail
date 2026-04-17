import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../services/pet_service.dart';

final petServiceProvider = Provider((ref) => PetService());
class PetNotifier extends Notifier<List<PetModel>> {
  StreamSubscription? _subscription;

  @override
  List<PetModel> build() {
    // Clean up when the provider is destroyed
    ref.onDispose(() => _subscription?.cancel());
    return [];
  }

  /// Listens to all pets belonging to a specific family
  void watchFamilyPets(String familyId) {
    // Cancel any existing subscription before starting a new one
    _subscription?.cancel();
    _subscription = ref.read(petServiceProvider).getPetStream(familyId).listen((snapshot) {
      state = snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();
    });
  }
}

final petProvider =
    NotifierProvider<PetNotifier, List<PetModel>>(() => PetNotifier());