import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tail/models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // One-time fetch of a user's profile data from the root collection.
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data();
  }
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  // Deletes a user's document from the users collection.
  Future<void> deleteUserProfile(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }

  // Family Dashboard methods

  // Fetches the logged-in parent's full UserModel 
  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Returns a real-time stream of all family members as UserModel objects.
  Stream<List<UserModel>> getFamilyMembers(String familyId) {
    return _db
        .collection('users')
        .where('family_id', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  Future<List<UserModel>> getFamilyMembersOnce(String familyId) async {
    final snapshot = await _db
        .collection('users')
        .where('family_id', isEqualTo: familyId)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }
  Future<void> addFamilyMember({
    required String name,
    required bool isPartner,
    required String familyId,
    required String parentUid,
  }) async {

    final String role = isPartner ? 'parent' : 'child';

    final newDoc = await _db.collection('users').add({
      'display_name': name,
      'role': role,
      'family_id': familyId,
      if (!isPartner) 'parent_id': parentUid,
      'total_points': 0,
      'claimed': false,
    });

    if (!isPartner) {
      await _db.collection('users').doc(parentUid).update({
        'children_id': FieldValue.arrayUnion([newDoc.id]),
      });
    }
  }

  // Renames a family member.
  Future<void> renameFamilyMember(String memberId, String newName) async {
    await updateUserProfile(memberId, {'display_name': newName});
  }

  // Removes a member from a family.
  // If the member has claimed their account: strips family fields but preserves
  // their Auth account and user document.
  // If unclaimed: deletes their placeholder document entirely.
  // In both cases, removes their ID from the parent's children_id array.
  Future<void> removeFamilyMember({
    required UserModel member,
    required String parentUid,
  }) async {
    if (member.claimed) {
      await _db.collection('users').doc(member.userId).update({
        'family_id': FieldValue.delete(),
        'parent_id': FieldValue.delete(),
      });
    } else {
      await _db.collection('users').doc(member.userId).delete();
    }

    // Remove from the parent's children_id array regardless of claimed status.
    // This is a no-op if the member is a partner (not in the array).
    await _db.collection('users').doc(parentUid).update({
      'children_id': FieldValue.arrayRemove([member.userId]),
    });
  }
}
