import 'package:intl/intl.dart';

class Payment {
  final String id;
  final String householdId;
  final String? apartmentId;
  final String? apartmentNumber;
  final String paymentType;
  final double amount;
  final DateTime? paymentDate;
  final String status;
  final String? notes;
  final DateTime? dueDate;

  Payment({
    required this.id,
    required this.householdId,
    this.apartmentId,
    this.apartmentNumber,
    required this.paymentType,
    required this.amount,
    this.paymentDate,
    required this.status,
    this.notes,
    this.dueDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    // Parse amount safely
    double parsedAmount = 0.0;
    if (json['amount'] != null) {
      if (json['amount'] is String) {
        parsedAmount = double.tryParse(json['amount']) ?? 0.0;
      } else if (json['amount'] is num) {
        parsedAmount = (json['amount'] as num).toDouble();
      }
    }

    return Payment(
      id: json['payment_id']?.toString() ?? '',
      householdId: json['household_id']?.toString() ?? '',
      apartmentId: json['apartment_id']?.toString(),
      apartmentNumber: json['apartment_number']?.toString(),
      paymentType: json['payment_type']?.toString() ?? 'N/A',
      amount: parsedAmount,
      paymentDate: json['payment_date'] != null ? DateTime.tryParse(json['payment_date'].toString()) : null,
      status: json['status']?.toString() ?? PaymentStatus.pending,
      notes: json['notes']?.toString(),
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'household_id': householdId,
      'payment_type': paymentType,
      'amount': amount,
      'payment_date': paymentDate?.toIso8601String().split('T')[0],
      'status': status,
      'notes': notes,
      'due_date': dueDate?.toIso8601String().split('T')[0],
    };
  }

  // Helper for display
  String get formattedPaymentDate => paymentDate != null ? DateFormat('dd/MM/yyyy').format(paymentDate!) : 'N/A';
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