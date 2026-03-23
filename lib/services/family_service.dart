import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/family_model.dart';

const int kMaxParents = 1;
const int kMaxChildren = 3;

class FamilyRole {
  static const String parent = 'Parent';
  static const String child = 'Child';
}

class FamilyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<Map<String, dynamic>?> streamFamilyData(String familyId) {
    return _db
        .collection('Families')
        .doc(familyId)
        .snapshots()
        .map((doc) => doc.data());
  }

  /// Creates the family document and immediately adds the creator as a Parent
  Future<void> createFamily(String familyId, FamilyModel family) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No user logged in');

    await _db
        .collection('Families')
        .doc(familyId)
        .set(family.toFirestore());

    // Add the creator to the members list as a Parent
    await addMember(familyId, uid, FamilyRole.parent);
  }

  Future<FamilyModel?> getFamilyById(String familyId) async {
    try {
      final docSnapshot =
          await _db.collection('Families').doc(familyId).get();
      if (!docSnapshot.exists) return null;
      // ignore: unnecessary_cast
      final snapshot = docSnapshot as DocumentSnapshot<Map<String, dynamic>>;
      return FamilyModel.fromFirestore(snapshot);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateFamily(String familyId, Map<String, dynamic> data) {
    return _db.collection('Families').doc(familyId).update(data);
  }

  /// Returns true if the given role still has room in the family
  Future<bool> canAddMember(String familyId, String role) async {
    final family = await getFamilyById(familyId);
    if (family == null) return false;

    final int parentCount =
        family.members.where((m) => m.role == FamilyRole.parent).length;
    final int childCount =
        family.members.where((m) => m.role == FamilyRole.child).length;

    if (role == FamilyRole.parent) return parentCount < kMaxParents;
    if (role == FamilyRole.child) return childCount < kMaxChildren;

    return false;
  }

  /// Safely adds a member using a transaction to prevent race conditions
  Future<void> addMember(
      String familyId, String memberId, String role) async {
    final familyRef = _db.collection('Families').doc(familyId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(familyRef);
      if (!snapshot.exists) throw Exception('Family not found');

      final data = snapshot.data() as Map<String, dynamic>;
      final List members = data['members'] ?? [];

      final int parentCount =
          members.where((m) => m['role'] == FamilyRole.parent).length;
      final int childCount =
          members.where((m) => m['role'] == FamilyRole.child).length;

      if (role == FamilyRole.parent && parentCount >= kMaxParents) {
        throw Exception('Family already has a Parent');
      }
      if (role == FamilyRole.child && childCount >= kMaxChildren) {
        throw Exception(
            'Family has reached the maximum of $kMaxChildren Children');
      }

      transaction.update(familyRef, {
        'members': FieldValue.arrayUnion([
          {'id': memberId, 'role': role}
        ]),
      });
    });
  }
}