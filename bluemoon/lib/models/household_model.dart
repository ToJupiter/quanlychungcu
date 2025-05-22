import './apartment_model.dart'; // May be needed if embedding Apartment object
import './resident_model.dart';
import './vehicle_model.dart';

class Household {
  final String id;
  final String apartmentId; // Store the ID of the linked apartment
  final String apartmentNumber; // For display purposes
  final double apartmentArea;
  final String apartmentStatus;
  final String headResidentId;
  final String headResidentName;
  final DateTime? headResidentDob;
  final String? headResidentCccd;
  final DateTime moveInDate;
  final List<Resident> residents;
  final List<Vehicle> vehicles;
  // final Apartment? apartment; // Alternative: embed the full Apartment object

  Household({
    required this.id,
    required this.apartmentId,
    required this.apartmentNumber,
    required this.apartmentArea,
    required this.apartmentStatus,
    required this.headResidentId,
    required this.headResidentName,
    this.headResidentDob,
    this.headResidentCccd,
    required this.moveInDate,
    this.residents = const [],
    this.vehicles = const [],
    // this.apartment,
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    // Parse area safely
    double area = 0.0;
    if (json['apartment_area'] != null) {
      if (json['apartment_area'] is String) {
        area = double.tryParse(json['apartment_area']) ?? 0.0;
      } else if (json['apartment_area'] is num) {
        area = (json['apartment_area'] as num).toDouble();
      }
    }

    // Parse residents if available
    List<Resident> residentsList = [];
    if (json['residents'] != null && json['residents'] is List) {
      residentsList = (json['residents'] as List)
          .map((r) => Resident.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    // Parse vehicles if available
    List<Vehicle> vehiclesList = [];
    if (json['vehicles'] != null && json['vehicles'] is List) {
      vehiclesList = (json['vehicles'] as List)
          .map((v) => Vehicle.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    return Household(
      id: json['household_id']?.toString() ?? '',
      apartmentId: json['apartment_id']?.toString() ?? '',
      apartmentNumber: json['apartment_number']?.toString() ?? 'N/A',
      apartmentArea: area,
      apartmentStatus: json['apartment_status']?.toString() ?? 'unknown',
      headResidentId: json['head_resident_id']?.toString() ?? '',
      headResidentName: json['head_full_name']?.toString() ?? 'N/A',
      headResidentDob: json['head_dob'] != null ? DateTime.tryParse(json['head_dob'].toString()) : null,
      headResidentCccd: json['head_cccd']?.toString(),
      moveInDate: json['move_in_date'] != null 
          ? DateTime.tryParse(json['move_in_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      residents: residentsList,
      vehicles: vehiclesList,
      // apartment: json['apartment'] != null ? Apartment.fromJson(json['apartment']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Primarily for sending data to create/update household
    return {
      'apartment_id': apartmentId,
      'move_in_date': moveInDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'head_full_name': headResidentName,
      'head_date_of_birth': headResidentDob?.toIso8601String().split('T')[0],
      'head_cccd_number': headResidentCccd,
      // apartmentNumber is for display, not usually sent back directly in this object
    };
  }
} 