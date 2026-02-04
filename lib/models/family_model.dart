class FamilyModel {
  final String familyId; // This will hold the Document ID from Firestore
  final String adminId;
  final List<String> memberIds;

  FamilyModel({
    required this.familyId,
    required this.adminId,
    required this.memberIds,
  });

  factory FamilyModel.fromFirestore(Map<String, dynamic> data, String id) {
    return FamilyModel(
      familyId: id, // Use the ID passed from the database document
      adminId: data['Admin_id'] ?? "", // Add a fallback
      memberIds: List<String>.from(data['member_ids'] ?? []), // Cast to String List
    );
  }
}//To Do write Map