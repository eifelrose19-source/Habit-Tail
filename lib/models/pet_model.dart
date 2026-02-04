import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String petId; // Document ID
  final String familyId;
  final String name;
  final String breed;
  final String gender;
  final int age;
  final String type;

  PetModel({
    required this.petId,
    required this.familyId,
    required this.name,
    required this.breed,
    required this.gender,
    required this.age,
    required this.type,
  });

  /// Factory constructor using DocumentSnapshot to handle ID and data at once
  factory PetModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return PetModel(
      petId: doc.id,
      familyId: data['Family_id'] ?? "",
      name: data['Name'] ?? "",
      breed: data['Breed'] ?? "",
      gender: data['Gender'] ?? "",
      age: (data['Age'] as num?)?.toInt() ?? 0, // Handles int/double safely
      type: data['Type'] ?? "",
    );
  }

  /// Converts model to Map for Firestore using your specific PascalCase keys
  Map<String, dynamic> toFirestore() {
    return {
      'Family_id': familyId,
      'Name': name,
      'Breed': breed,
      'Gender': gender,
      'Age': age,
      'Type': type,
    };
  }

  /// Returns a new instance with updated fields for easier state management
  PetModel copyWith({
    String? petId,
    String? familyId,
    String? name,
    String? breed,
    String? gender,
    int? age,
    String? type,
  }) {
    return PetModel(
      petId: petId ?? this.petId,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PetModel &&
        other.petId == petId &&
        other.familyId == familyId &&
        other.name == name &&
        other.breed == breed &&
        other.gender == gender &&
        other.age == age &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(petId, familyId, name, breed, gender, age, type);
  }

  @override
  String toString() {
    return 'PetModel(petId: $petId, familyId: $familyId, name: $name, breed: $breed, gender: $gender, age: $age, type: $type)';
  }

  /// Compatibility factory used by older repositories expecting `fromMap`
  factory PetModel.fromMap(Map<String, dynamic> map, String id) {
    final rawAge = map['Age'] ?? map['age'];
    int parsedAge = 0;
    if (rawAge is num) {
      parsedAge = rawAge.toInt();
    } else if (rawAge is String) {
      parsedAge = int.tryParse(rawAge) ?? 0;
    }

    return PetModel(
      petId: id,
      familyId: map['Family_id'] ?? "",
      name: map['Name'] ?? map['name'] ?? "",
      breed: map['Breed'] ?? map['breed'] ?? "",
      gender: map['Gender'] ?? map['gender'] ?? "",
      age: parsedAge,
      type: map['Type'] ?? map['type'] ?? "",
    );
  }
}

extension PetModelCompat on PetModel {
  String get id => petId;

  Map<String, dynamic> toMap() => toFirestore();
}

/// Backwards-compatible `Pet` shape used by older tests and code.
class Pet {
  final String id;
  final String name;
  final String breed;
  final String gender;
  final int age;
  final String type;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.gender,
    required this.age,
    required this.type,
  });

  factory Pet.fromMap(String id, Map<String, dynamic> map) {
    final model = PetModel.fromMap(map, id);
    return Pet(
      id: model.petId,
      name: model.name,
      breed: model.breed,
      gender: model.gender,
      age: model.age,
      type: model.type,
    );
  }
}
