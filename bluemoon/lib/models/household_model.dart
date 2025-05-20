import './apartment_model.dart'; // May be needed if embedding Apartment object

class Household {
  final String id;
  final String apartmentId; // Store the ID of the linked apartment
  final String apartmentNumber; // For display purposes
  final String headResidentName;
  final DateTime moveInDate;
  // final Apartment? apartment; // Alternative: embed the full Apartment object

  Household({
    required this.id,
    required this.apartmentId,
    required this.apartmentNumber,
    required this.headResidentName,
    required this.moveInDate,
    // this.apartment,
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    // The backend GET /api/management/households seems to join apartment details.
    // So, we expect apartment_details.apartment_number or similar.
    // Adjust based on actual API response structure.
    String aptNumber = 'N/A';
    if (json['apartment_details'] != null && json['apartment_details']['apartment_number'] != null) {
      aptNumber = json['apartment_details']['apartment_number'] as String;
    } else if (json['apartment'] != null && json['apartment']['apartmentNumber'] != null) {
       // Fallback if structure is different, e.g. from a direct Apartment object embedding
      aptNumber = json['apartment']['apartmentNumber'] as String;
    } else if (json['apartmentNumber'] != null) {
        // Direct field
        aptNumber = json['apartmentNumber'] as String;
    }


    return Household(
      id: json['_id'] ?? json['id'] as String,
      apartmentId: json['apartment_id'] as String,
      apartmentNumber: aptNumber, // Handled above
      headResidentName: json['head_resident_name'] as String,
      moveInDate: DateTime.parse(json['move_in_date'] as String),
      // apartment: json['apartment'] != null ? Apartment.fromJson(json['apartment']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Primarily for sending data to create/update household
    return {
      'apartment_id': apartmentId,
      'head_resident_name': headResidentName,
      'move_in_date': moveInDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      // apartmentNumber is for display, not usually sent back directly in this object
    };
  }
} 