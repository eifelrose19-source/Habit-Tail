import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String petId;
  final String familyId;
  final String name;
  final String breed;
  final String gender;
  final int age;
  final String type;
  final String petMeds;
  final String vetNumber;
  final String vetOffice;
  final String veterinarian;
  final String petLicense;

  PetModel({
    required this.petId,
    required this.familyId,
    required this.name,
    required this.breed,
    required this.gender,
    required this.age,
    required this.type,
    required this.petMeds,
    required this.vetNumber,
    required this.vetOffice,
    required this.veterinarian,
    required this.petLicense,
  });

  /// Factory constructor to create a PetModel from Firestore
  factory PetModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return PetModel(
      petId: doc.id,
      familyId: data['family_id'] ?? "",
      name: data['name'] ?? "",
      breed: data['breed'] ?? "",
      gender: data['gender'] ?? "",
      age: (data['age'] as num?)?.toInt() ?? 0,
      type: data['type'] ?? "",
      petMeds: data['pet_meds'] ?? "",
      vetNumber: data['vet_number'] ?? "",
      vetOffice: data['vet_office'] ?? "",
      veterinarian: data['veterinarian'] ?? "",
      petLicense: data['pet_license'] ?? "",
    );
  }

  /// Converts the PetModel to a Map for saving to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'family_id': familyId,
      'name': name,
      'breed': breed,
      'gender': gender,
      'age': age,
      'type': type,
      'pet_meds': petMeds,
      'vet_number': vetNumber,
      'vet_office': vetOffice,
      'veterinarian': veterinarian,
      'pet_license': petLicense,
    };
  }

  /// CopyWith for Riverpod state management updates
  PetModel copyWith({
    String? petId,
    String? familyId,
    String? name,
    String? breed,
    String? gender,
    int? age,
    String? type,
    String? petMeds,
    String? vetNumber,
    String? vetOffice,
    String? veterinarian,
    String? petLicense,
  }) {
    return PetModel(
      petId: petId ?? this.petId,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      type: type ?? this.type,
      petMeds: petMeds ?? this.petMeds,
      vetNumber: vetNumber ?? this.vetNumber,
      vetOffice: vetOffice ?? this.vetOffice,
      veterinarian: veterinarian ?? this.veterinarian,
      petLicense: petLicense ?? this.petLicense,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetModel && other.petId == petId;
  }

  @override
  int get hashCode => petId.hashCode;

  @override
  String toString() => 'PetModel(name: $name, type: $type)';
}