class Apartment {
  final String id;
  final String apartmentNumber;
  final double area;
  final String status; // e.g., 'occupied', 'vacant'

  Apartment({
    required this.id,
    required this.apartmentNumber,
    required this.area,
    required this.status,
  });

  // Optional: Factory constructor for JSON parsing
  factory Apartment.fromJson(Map<String, dynamic> json) {
    // Parse area safely
    double parsedArea = 0.0;
    if (json['area'] != null) {
      if (json['area'] is String) {
        parsedArea = double.tryParse(json['area']) ?? 0.0;
      } else if (json['area'] is num) {
        parsedArea = (json['area'] as num).toDouble();
      }
    }

    return Apartment(
      id: json['apartment_id']?.toString() ?? '',
      apartmentNumber: json['apartment_number']?.toString() ?? 'N/A',
      area: parsedArea,
      status: json['status']?.toString() ?? 'unknown',
    );
  }

  // Optional: Method to convert to JSON (for sending data to backend)
  Map<String, dynamic> toJson() {
    return {
      'apartment_number': apartmentNumber,
      'area': area,
      'status': status,
      // id is usually not sent back for create/update in this way, 
      // or if it is, it might be part of the URL or a specific field.
    };
  }
} 