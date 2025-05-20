class Vehicle {
  final String id; // UUID or ID from backend
  final String householdId; // To link back to the household
  String plateNumber;
  String? vehicleType;
  DateTime? registrationDate;

  Vehicle({
    required this.id,
    required this.householdId,
    required this.plateNumber,
    this.vehicleType,
    this.registrationDate,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? json['id'] as String,
      householdId: json['household_id'] as String, // Assuming backend provides this
      plateNumber: json['plate_number'] as String,
      vehicleType: json['vehicle_type'] as String?,
      registrationDate: json['registration_date'] != null ? DateTime.parse(json['registration_date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'household_id': householdId,
      'plate_number': plateNumber,
      'vehicle_type': vehicleType,
      'registration_date': registrationDate?.toIso8601String().split('T')[0], // YYYY-MM-DD
    };
  }
} 