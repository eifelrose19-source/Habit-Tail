import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_model.dart';
import '../repositories/family_repository.dart';

class FamilyNotifier extends Notifier<List<FamilyModel>> {
  final FamilyRepository _repo = FamilyRepository();

  @override
  List<FamilyModel> build() => [];

  void startListening(String familyId) {
    _repo.watchFamily(familyId).listen((updated) {
      state = updated;
    });
  }
}

final familyProvider =
    NotifierProvider<FamilyNotifier, List<FamilyModel>>(() => FamilyNotifier());