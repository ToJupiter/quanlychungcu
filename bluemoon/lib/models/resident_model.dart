class Resident {
  final String id;
  final String householdId;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? cccdNumber;
  final String? roleInHousehold;

  Resident({
    required this.id,
    required this.householdId,
    required this.fullName,
    this.dateOfBirth,
    this.cccdNumber,
    this.roleInHousehold,
  });

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      id: json['resident_id']?.toString() ?? '',
      householdId: json['household_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'N/A',
      dateOfBirth: json['date_of_birth'] != null ? DateTime.tryParse(json['date_of_birth'].toString()) : null,
      cccdNumber: json['cccd_number']?.toString(),
      roleInHousehold: json['role_in_household']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'household_id': householdId,
      'full_name': fullName,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'cccd_number': cccdNumber,
      'role_in_household': roleInHousehold,
    };
  }
} 