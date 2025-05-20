class Resident {
  final String id; // UUID or ID from backend
  final String householdId; // To link back to the household
  String fullName;
  DateTime? dateOfBirth;
  String? cccdNumber; // National ID
  String? roleInHousehold; // e.g., 'Member', 'Tenant', 'Child'

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
      id: json['_id'] ?? json['id'] as String,
      householdId: json['household_id'] as String, // Assuming backend provides this
      fullName: json['full_name'] as String,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      cccdNumber: json['cccd_number'] as String?,
      roleInHousehold: json['role_in_household'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Usually not sent on create, and part of URL on update
      'household_id': householdId, // Needed for creating a resident under a household
      'full_name': fullName,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0], // YYYY-MM-DD
      'cccd_number': cccdNumber,
      'role_in_household': roleInHousehold,
    };
  }
} 