import 'package:intl/intl.dart';

class Payment {
  final String id;
  final String householdId;
  final String? apartmentNumber; // For display, might need to be fetched/joined
  final String paymentType; // e.g., "Tiền điện", "Tiền nước", "Phí quản lý"
  final double amount;
  final DateTime? paymentDate; // Made nullable
  final String status; // e.g., "Chưa thanh toán", "Đã thanh toán", "Quá hạn"
  final String? notes;
  final DateTime? dueDate;

  Payment({
    required this.id,
    required this.householdId,
    this.apartmentNumber,
    required this.paymentType,
    required this.amount,
    this.paymentDate, // Adjusted constructor
    required this.status,
    this.notes,
    this.dueDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['payment_id']?.toString() ?? '', // Handle potential null
      householdId: json['household_id']?.toString() ?? '', // Handle potential null
      apartmentNumber: json['apartment_number'] as String?,
      paymentType: json['payment_type'] as String? ?? 'N/A',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['payment_date'] != null ? DateTime.tryParse(json['payment_date'].toString()) : null, // Use tryParse, handle if not string
      status: json['status'] as String? ?? 'Unknown',
      notes: json['notes'] as String?,
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'].toString()) : null, // Use tryParse
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'payment_type': paymentType,
      'amount': amount,
      'payment_date': paymentDate != null ? DateFormat('yyyy-MM-dd').format(paymentDate!) : null, // Handle null
      'status': status,
      'notes': notes,
      'due_date': dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : null,
      // apartment_number is usually not sent back, it's for display
    };
  }

  // Helper for display
  String get formattedPaymentDate => paymentDate != null ? DateFormat('dd/MM/yyyy').format(paymentDate!) : 'N/A'; // Handle null
  String get formattedDueDate => dueDate != null ? DateFormat('dd/MM/yyyy').format(dueDate!) : 'N/A';
  String get formattedAmount => NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
}

// Example of statuses for dropdowns or filtering
class PaymentStatus {
  static const String pending = 'Chưa thanh toán';
  static const String paid = 'Đã thanh toán';
  static const String overdue = 'Quá hạn';
  static const String cancelled = 'Đã hủy';

  static List<String> get all => [pending, paid, overdue, cancelled];
}

class PaymentType {
  static const String electricity = 'Tiền điện';
  static const String water = 'Tiền nước';
  static const String managementFee = 'Phí quản lý';
  static const String parkingFee = 'Phí gửi xe';
  static const String serviceFee = 'Phí dịch vụ khác';

  static List<String> get all => [electricity, water, managementFee, parkingFee, serviceFee];
} 