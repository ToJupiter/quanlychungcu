import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/payment_model.dart';
import 'auth_service.dart'; // For token
import 'package:intl/intl.dart';

class PaymentService {
  final String _baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _authService.getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Payment>> fetchPayments({String? householdId, String? status, String? paymentType, String? monthYear}) async {
    try {
      final headers = await _getHeaders();
      
      Uri uri = Uri.parse('$_baseUrl/finance/payments');
      Map<String, String> queryParams = {};
      
      if (householdId != null && householdId.isNotEmpty) {
        queryParams['householdId'] = householdId;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (paymentType != null && paymentType.isNotEmpty) {
        queryParams['paymentType'] = paymentType;
      }
      if (monthYear != null && monthYear.isNotEmpty) {
        queryParams['monthYear'] = monthYear; // Expected format: YYYY-MM
      }
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        // Parse the response body
        final dynamic decodedBody = jsonDecode(response.body);
        
        // Handle different response formats
        List<dynamic> paymentsList;
        if (decodedBody is Map && decodedBody.containsKey('data') && decodedBody['data'] is List) {
          paymentsList = decodedBody['data'] as List<dynamic>;
        } else if (decodedBody is List) {
          paymentsList = decodedBody;
        } else {
          print('Unexpected response format for payments: $decodedBody');
          throw Exception('Unexpected response format for payments');
        }
        
        // Convert each payment JSON to a Payment object
        List<Payment> payments = paymentsList
            .map((dynamic item) => Payment.fromJson(item as Map<String, dynamic>))
            .toList();
            
        return payments;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Unauthorized. Please login again.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to load payments: ${errorBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('PaymentService fetchPayments Error: $e');
      throw Exception('Failed to load payments: $e');
    }
  }

  Future<Payment> fetchPaymentById(String paymentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/finance/payments/$paymentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);
        Map<String, dynamic> paymentData;
        
        if (decodedBody is Map && decodedBody.containsKey('data') && decodedBody['data'] is Map) {
          paymentData = decodedBody['data'] as Map<String, dynamic>;
        } else if (decodedBody is Map) {
          paymentData = decodedBody as Map<String, dynamic>;
        } else {
          throw Exception('Unexpected response format for payment details');
        }
        
        return Payment.fromJson(paymentData);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to load payment details: ${errorBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('PaymentService fetchPaymentById Error: $e');
      throw Exception('Failed to load payment details: $e');
    }
  }

  Future<Payment> createPayment(Map<String, dynamic> paymentData) async {
    try {
      final headers = await _getHeaders();
      
      // Ensure numeric values are sent as numbers, not strings
      if (paymentData.containsKey('amount') && paymentData['amount'] is String) {
        paymentData['amount'] = double.tryParse(paymentData['amount']) ?? 0.0;
      }
      
      // Ensure IDs are sent as strings
      if (paymentData.containsKey('household_id') && paymentData['household_id'] is int) {
        paymentData['household_id'] = paymentData['household_id'].toString();
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/finance/payments'),
        headers: headers,
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);
        Map<String, dynamic> responseData;
        
        if (decodedBody is Map && decodedBody.containsKey('data') && decodedBody['data'] is Map) {
          responseData = decodedBody['data'] as Map<String, dynamic>;
        } else if (decodedBody is Map) {
          responseData = decodedBody as Map<String, dynamic>;
        } else {
          throw Exception('Unexpected response format for created payment');
        }
        
        return Payment.fromJson(responseData);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to create payment: ${errorBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('PaymentService createPayment Error: $e');
      throw Exception('Failed to create payment: $e');
    }
  }

  Future<Payment> updatePayment(String paymentId, Map<String, dynamic> paymentData) async {
    try {
      final headers = await _getHeaders();
      
      // Ensure numeric values are sent as numbers, not strings
      if (paymentData.containsKey('amount') && paymentData['amount'] is String) {
        paymentData['amount'] = double.tryParse(paymentData['amount']) ?? 0.0;
      }
      
      // Ensure IDs are sent as strings
      if (paymentData.containsKey('household_id') && paymentData['household_id'] is int) {
        paymentData['household_id'] = paymentData['household_id'].toString();
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/finance/payments/$paymentId'),
        headers: headers,
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);
        Map<String, dynamic> responseData;
        
        if (decodedBody is Map && decodedBody.containsKey('data') && decodedBody['data'] is Map) {
          responseData = decodedBody['data'] as Map<String, dynamic>;
        } else if (decodedBody is Map) {
          responseData = decodedBody as Map<String, dynamic>;
        } else {
          throw Exception('Unexpected response format for updated payment');
        }
        
        return Payment.fromJson(responseData);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to update payment: ${errorBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('PaymentService updatePayment Error: $e');
      throw Exception('Failed to update payment: $e');
    }
  }

  Future<void> deletePayment(String paymentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/finance/payments/$paymentId'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Success
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to delete payment: ${errorBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('PaymentService deletePayment Error: $e');
      throw Exception('Failed to delete payment: $e');
    }
  }

  Future<Payment> updatePaymentStatus(String paymentId, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl/finance/payments/$paymentId/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);
        Map<String, dynamic> responseData;
        
        if (decodedBody is Map && decodedBody.containsKey('data') && decodedBody['data'] is Map) {
          responseData = decodedBody['data'] as Map<String, dynamic>;
        } else if (decodedBody is Map) {
          responseData = decodedBody as Map<String, dynamic>;
        } else {
          throw Exception('Unexpected response format for payment status update');
        }
        
        return Payment.fromJson(responseData);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to update payment status: ${errorBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('PaymentService updatePaymentStatus Error: $e');
      throw Exception('Failed to update payment status: $e');
    }
  }

  Future<Map<String, dynamic>> fetchFinancialSummary({String? monthYear, String? startDate, String? endDate}) async {
    try {
      final headers = await _getHeaders();
      
      Uri uri = Uri.parse('$_baseUrl/finance/reports/financial-summary');
      Map<String, String> queryParams = {};

      if (startDate != null && startDate.isNotEmpty && endDate != null && endDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
        queryParams['endDate'] = endDate;
      } else if (monthYear != null && monthYear.isNotEmpty) {
        try {
          final year = int.parse(monthYear.substring(0, 4));
          final month = int.parse(monthYear.substring(5, 7));
          final firstDayOfMonth = DateTime(year, month, 1);
          final lastDayOfMonth = DateTime(year, month + 1, 0);
          
          queryParams['startDate'] = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
          queryParams['endDate'] = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);
        } catch (e) {
          throw Exception('Invalid monthYear format. Expected YYYY-MM: $e');
        }
      }

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);
        Map<String, dynamic> reportData;
        
        if (decodedBody is Map && decodedBody.containsKey('data') && decodedBody['data'] is Map) {
          reportData = decodedBody['data'] as Map<String, dynamic>;
        } else if (decodedBody is Map) {
          reportData = decodedBody as Map<String, dynamic>;
        } else {
          throw Exception('Unexpected response format for financial summary');
        }
        
        // Parse numeric values in the report
        if (reportData.containsKey('totalCollected') && reportData['totalCollected'] != null) {
          reportData['totalCollected'] = _parseNumericValue(reportData['totalCollected']);
        }
        
        if (reportData.containsKey('totalDueInPeriod') && reportData['totalDueInPeriod'] != null) {
          reportData['totalDueInPeriod'] = _parseNumericValue(reportData['totalDueInPeriod']);
        }
        
        if (reportData.containsKey('totalOutstandingUnpaid') && reportData['totalOutstandingUnpaid'] != null) {
          reportData['totalOutstandingUnpaid'] = _parseNumericValue(reportData['totalOutstandingUnpaid']);
        }
        
        return reportData;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to load financial summary: ${errorBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('PaymentService fetchFinancialSummary Error: $e');
      throw Exception('Failed to load financial summary: $e');
    }
  }
  
  // Helper to parse numeric values that might be strings
  double _parseNumericValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
} 