import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Pet.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Pet.fromMap(doc.id, data);
  }

  /// Construct a [Pet] from a plain map. Useful for tests and non-Firestore sources.
  factory Pet.fromMap(String id, Map<String, dynamic> data) {
    return Pet(
      id: id,
      name: data['name'] as String? ?? '',
      breed: data['breed'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      age: (data['age'] is int)
          ? data['age'] as int
          : int.tryParse((data['age'] ?? '').toString()) ?? 0,
      type: data['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'breed': breed,
        'gender': gender,
        'age': age,
        'type': type,
      };
}