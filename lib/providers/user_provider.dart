import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _repo = UserRepository();
  UserModel? _user;

  UserModel? get user => _user;

  void startListening(String userId) {
    _repo.watchUser(userId).listen((updatedUser) {
      _user = updatedUser;
      notifyListeners();
    });
  }
}