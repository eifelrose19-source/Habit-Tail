import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'user_provider.dart';

final familyMembersProvider = StreamProvider<List<UserModel>>((ref) {
  final familyId = ref.watch(userProvider).user?.familyId ?? '';

  if (familyId.isEmpty) return const Stream.empty();

  final repository = ref.read(userRepositoryProvider);
  return repository.watchFamilyMembers(familyId);
});