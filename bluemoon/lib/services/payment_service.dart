import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/payment_model.dart';
import 'auth_service.dart'; // For token
import 'package:intl/intl.dart';

class PaymentService {
  final String _baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  Future<List<Payment>> fetchPayments({String? householdId, String? status, String? paymentType, String? monthYear}) async {
    String? token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please login again.');
    }

    Uri uri = Uri.parse('$_baseUrl/finance/payments');
    Map<String, String> queryParams = {};
    if (householdId != null && householdId.isNotEmpty) queryParams['householdId'] = householdId;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (paymentType != null && paymentType.isNotEmpty) queryParams['paymentType'] = paymentType;
    if (monthYear != null && monthYear.isNotEmpty) queryParams['monthYear'] = monthYear; // Expected format: YYYY-MM
    
    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['data'] ?? jsonDecode(response.body);
      List<Payment> payments = body.map((dynamic item) => Payment.fromJson(item)).toList();
      return payments;
    } else if (response.statusCode == 401) {
      await _authService.logout(); // Or handle token refresh
      throw Exception('Unauthorized. Please login again.');
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load payments: ${errorBody['message'] ?? response.reasonPhrase}');
    }
  }

  Future<Payment> fetchPaymentById(String paymentId) async {
    String? token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$_baseUrl/finance/payments/$paymentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body)['data'] ?? jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load payment details: ${errorBody['message'] ?? response.reasonPhrase}');
    }
  }

  Future<Payment> createPayment(Map<String, dynamic> paymentData) async {
    String? token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.post(
      Uri.parse('$_baseUrl/finance/payments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(paymentData),
    );

    if (response.statusCode == 201) {
      return Payment.fromJson(jsonDecode(response.body)['data'] ?? jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to create payment: ${errorBody['message'] ?? response.reasonPhrase}');
    }
  }

  Future<Payment> updatePayment(String paymentId, Map<String, dynamic> paymentData) async {
    String? token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.put(
      Uri.parse('$_baseUrl/finance/payments/$paymentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(paymentData),
    );

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body)['data'] ?? jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to update payment: ${errorBody['message'] ?? response.reasonPhrase}');
    }
  }

  Future<void> deletePayment(String paymentId) async {
    String? token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.delete(
      Uri.parse('$_baseUrl/finance/payments/$paymentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) { // 204 No Content also success
      return;
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete payment: ${errorBody['message'] ?? response.reasonPhrase}');
    }
  }

   Future<Payment> updatePaymentStatus(String paymentId, String status) async {
    String? token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.patch(
      Uri.parse('$_baseUrl/finance/payments/$paymentId/status'), // Assuming a PATCH endpoint for status update
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body)['data'] ?? jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to update payment status: ${errorBody['message'] ?? response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> fetchFinancialSummary({String? monthYear, String? startDate, String? endDate}) async {
    String? token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');

    Uri uri = Uri.parse('$_baseUrl/finance/reports/financial-summary');
    Map<String, String> queryParams = {};

    if (startDate != null && startDate.isNotEmpty && endDate != null && endDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
      queryParams['endDate'] = endDate;
    } else if (monthYear != null && monthYear.isNotEmpty) { // Expected format YYYY-MM
      // Calculate startDate and endDate from monthYear
      try {
        final year = int.parse(monthYear.substring(0, 4));
        final month = int.parse(monthYear.substring(5, 7));
        final firstDayOfMonth = DateTime(year, month, 1);
        final lastDayOfMonth = DateTime(year, month + 1, 0); // Day 0 of next month is last day of current
        
        queryParams['startDate'] = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
        queryParams['endDate'] = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);
      } catch (e) {
        throw Exception('Invalid monthYear format. Expected YYYY-MM. Error: $e');
      }
    }
    // If no dates provided, the backend might return overall summary or error, depending on its design.
    // For this fix, we ensure if monthYear is given, startDate and endDate are derived.
    // If specific startDate/endDate are given, they are used.

    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] ?? jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load financial summary: ${errorBody['message'] ?? response.reasonPhrase}');
    }
  }
} 