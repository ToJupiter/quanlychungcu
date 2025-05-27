import 'package:intl/intl.dart';

class Staff {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String status;
  final DateTime? createdAt;

  Staff({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.status,
    this.createdAt,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['staff_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      status: json['status']?.toString() ?? StaffStatus.active,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'status': status,
    };
  }

  Map<String, dynamic> toCreateJson({required String password}) {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
      'status': status,
    };
  }

  // Helper getters for display
  String get formattedCreatedAt => createdAt != null 
      ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt!) 
      : 'N/A';
      
  String get formattedCreatedDate => createdAt != null 
      ? DateFormat('dd/MM/yyyy').format(createdAt!) 
      : 'N/A';

  String get statusDisplayName => _getStatusDisplayName(status);

  String _getStatusDisplayName(String status) {
    switch (status) {
      case StaffStatus.active:
        return 'Hoạt động';
      case StaffStatus.inactive:
        return 'Không hoạt động';
      default:
        return status;
    }
  }

  // Create a copy with updated fields
  Staff copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? status,
    DateTime? createdAt,
  }) {
    return Staff(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Staff status constants
class StaffStatus {
  static const String active = 'active';
  static const String inactive = 'inactive';

  static List<String> get all => [active, inactive];
}

// Staff statistics model
class StaffStats {
  final int total;
  final int active;
  final int inactive;

  StaffStats({
    required this.total,
    required this.active,
    required this.inactive,
  });

  factory StaffStats.fromJson(Map<String, dynamic> json) {
    return StaffStats(
      total: json['total']?.toInt() ?? 0,
      active: json['active']?.toInt() ?? 0,
      inactive: json['inactive']?.toInt() ?? 0,
    );
  }
} 