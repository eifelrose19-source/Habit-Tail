import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tail/models/pet_model.dart';

void main() {
  group('Pet.fromMap', () {
    test('parses full valid data', () {
      final map = {
        'name': 'Fido',
        'breed': 'Beagle',
        'gender': 'M',
        'age': 3,
        'type': 'Dog',
      };

      final pet = Pet.fromMap('abc123', map);

      expect(pet.id, 'abc123');
      expect(pet.name, 'Fido');
      expect(pet.breed, 'Beagle');
      expect(pet.gender, 'M');
      expect(pet.age, 3);
      expect(pet.type, 'Dog');
    });

    test('handles age as string', () {
      final map = {'name': 'Milo', 'age': '4'};

      final pet = Pet.fromMap('id2', map);

      expect(pet.name, 'Milo');
      expect(pet.age, 4);
    });

    test('handles missing fields with defaults', () {
      final pet = Pet.fromMap('id3', {});

      expect(pet.id, 'id3');
      expect(pet.name, '');
      expect(pet.breed, '');
      expect(pet.gender, '');
      expect(pet.age, 0);
      expect(pet.type, '');
    });
  });
}
