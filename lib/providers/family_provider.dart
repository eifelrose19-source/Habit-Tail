import 'package:flutter/material.dart';
import '../models/family_model.dart';
import '../repositories/family_repository.dart';

class FamilyProvider with ChangeNotifier {
  final FamilyRepository _repo = FamilyRepository();
  FamilyModel? _family;

  FamilyModel? get family => _family;

  void startListening(String familyId) {
    _repo.watchFamily(familyId).listen((updatedFamily) {
      _family = updatedFamily;
      notifyListeners();
    });
  }
}