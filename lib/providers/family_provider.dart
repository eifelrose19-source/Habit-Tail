import 'dart:async';
import 'package:flutter/material.dart';
import '../models/family_model.dart';
import '../repositories/family_repository.dart';
import 'dart:developer' as developer;

class FamilyProvider with ChangeNotifier {
  final FamilyRepository _repo = FamilyRepository();
  StreamSubscription<FamilyModel?>? _subscription;
  FamilyModel? _family;

  FamilyModel? get family => _family;

  void startListening(String familyId) {
    _subscription?.cancel();
    _subscription = _repo.watchFamily(familyId).listen(
      (updatedFamily) {
        _family = updatedFamily;
        notifyListeners();
      },
      onError: (error) {
        developer.log('FamilyProvider stream error: $error',
            name: 'FamilyProvider');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
