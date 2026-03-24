import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_model.dart';
import '../repositories/pet_repository.dart';

class PetNotifier extends Notifier<List<PetModel>> {
  final PetRepository _repo = PetRepository();

  @override
  List<PetModel> build() => [];

  void startListening(String familyId) {
    _repo.watchPets(familyId).listen((updated) {
      state = updated;
    });
  }
}

final petProvider =
    NotifierProvider<PetNotifier, List<PetModel>>(() => PetNotifier());