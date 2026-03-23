import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../repositories/pet_repository.dart';
import 'dart:developer' as developer;

class PetProvider with ChangeNotifier {
  final PetRepository _repo = PetRepository();
  StreamSubscription<List<PetModel>>? _subscription;
  List<PetModel> _pets = [];

  List<PetModel> get pets => _pets;

  void startListening(String familyId) {
    _subscription?.cancel();
    _subscription = _repo.watchPets(familyId).listen(
      (updatedPets) {
        _pets = updatedPets;
        notifyListeners();
      },
      onError: (error) {
        developer.log('PetProvider stream error: $error',
            name: 'PetProvider');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
