import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../repositories/pet_repository.dart';

class PetProvider with ChangeNotifier {
  final PetRepository _repo = PetRepository();
  List<PetModel> _pets = [];

  List<PetModel> get pets => _pets;

  void startListening(String familyId) {
    _repo.watchPets(familyId).listen((updatedPets) {
      _pets = updatedPets;
      notifyListeners();
    });
  }
}
