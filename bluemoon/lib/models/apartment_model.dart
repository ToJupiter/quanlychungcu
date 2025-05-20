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
    return Apartment(
      id: json['apartment_id']?.toString() ?? (json['_id']?.toString() ?? ''), // Handle potential null for id, provide empty string as fallback
      apartmentNumber: json['apartment_number'] as String? ?? 'N/A', // Handle potential null
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'unknown',
    );
  }

  // Optional: Method to convert to JSON (for sending data to backend)
  Map<String, dynamic> toJson() {
    return {
      'apartmentNumber': apartmentNumber,
      'area': area,
      'status': status,
      // id is usually not sent back for create/update in this way, 
      // or if it is, it might be part of the URL or a specific field.
    };
  }
} 