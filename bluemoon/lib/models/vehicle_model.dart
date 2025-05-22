class Vehicle {
  final String id;
  final String householdId;
  final String plateNumber;
  final String? vehicleType;
  final DateTime? registrationDate;

  Vehicle({
    required this.id,
    required this.householdId,
    required this.plateNumber,
    this.vehicleType,
    this.registrationDate,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['vehicle_id']?.toString() ?? '',
      householdId: json['household_id']?.toString() ?? '',
      plateNumber: json['plate_number']?.toString() ?? 'N/A',
      vehicleType: json['vehicle_type']?.toString(),
      registrationDate: json['registration_date'] != null 
          ? DateTime.tryParse(json['registration_date'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'household_id': householdId,
      'plate_number': plateNumber,
      'vehicle_type': vehicleType,
      'registration_date': registrationDate?.toIso8601String().split('T')[0],
    };
  }
} 