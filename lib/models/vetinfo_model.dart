import 'package:cloud_firestore/cloud_firestore.dart';

class VetOffice {
  final String city;
  final String state;
  final String streetAddress;
  final String zip;

  VetOffice({
    required this.city,
    required this.state,
    required this.streetAddress,
    required this.zip,
  });

  factory VetOffice.fromFirestore(Map<String, dynamic> data) {
    return VetOffice(
      city: data['City'] ?? "",
      state: data['State'] ?? "",
      streetAddress: data['Street_address'] ?? "",
      zip: data['Zip'] ?? "",
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'City': city,
      'State': state,
      'Street_address': streetAddress,
      'Zip': zip,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VetOffice &&
          city == other.city &&
          state == other.state &&
          streetAddress == other.streetAddress &&
          zip == other.zip;

  @override
  int get hashCode => Object.hash(city, state, streetAddress, zip);
}

class PetVetInfoModel {
  final String vetInfoId; // Document ID
  final String licenseNumber;
  final String petMeds;
  final String petMedicalInfo;
  final VetOffice vetOffice;
  final String veterinarian;

  PetVetInfoModel({
    required this.vetInfoId,
    required this.licenseNumber,
    required this.petMeds,
    required this.petMedicalInfo,
    required this.vetOffice,
    required this.veterinarian,
  });

  /// Factory constructor using DocumentSnapshot to handle ID and data at once
  factory PetVetInfoModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return PetVetInfoModel(
      vetInfoId: doc.id,
      licenseNumber: data['License_number'] ?? "",
      petMeds: data['Pet_meds'] ?? "",
      petMedicalInfo: data['Pet_medical_info'] ?? "",
      vetOffice: VetOffice.fromFirestore(data['Vet-office'] ?? {}),
      veterinarian: data['Veterinarian'] ?? "",
    );
  }

  /// Converts model to Map for Firestore using your specific keys
  Map<String, dynamic> toFirestore() {
    return {
      'License_number': licenseNumber,
      'Pet_meds': petMeds,
      'Pet_medical_info': petMedicalInfo,
      'Vet-office': vetOffice.toFirestore(),
      'Veterinarian': veterinarian,
    };
  }

  /// Returns a new instance with updated fields for easier state management
  PetVetInfoModel copyWith({
    String? vetInfoId,
    String? licenseNumber,
    String? petMeds,
    String? petMedicalInfo,
    VetOffice? vetOffice,
    String? veterinarian,
  }) {
    return PetVetInfoModel(
      vetInfoId: vetInfoId ?? this.vetInfoId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      petMeds: petMeds ?? this.petMeds,
      petMedicalInfo: petMedicalInfo ?? this.petMedicalInfo,
      vetOffice: vetOffice ?? this.vetOffice,
      veterinarian: veterinarian ?? this.veterinarian,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PetVetInfoModel &&
        other.vetInfoId == vetInfoId &&
        other.licenseNumber == licenseNumber &&
        other.petMeds == petMeds &&
        other.petMedicalInfo == petMedicalInfo &&
        other.vetOffice == vetOffice &&
        other.veterinarian == veterinarian;
  }

  @override
  int get hashCode {
    return Object.hash(
      vetInfoId,
      licenseNumber,
      petMeds,
      petMedicalInfo,
      vetOffice,
      veterinarian,
    );
  }

  @override
  String toString() {
    return 'PetVetInfoModel(vetInfoId: $vetInfoId, veterinarian: $veterinarian, office: ${vetOffice.city})';
  }
}