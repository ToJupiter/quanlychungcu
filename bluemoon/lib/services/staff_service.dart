import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/staff_model.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';

class StaffService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  // Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Fetch all staff members with optional filtering
  Future<List<Staff>> fetchStaff({String? status, String? search}) async {
    try {
      final headers = await _getHeaders();
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      final uri = Uri.parse('$baseUrl/staff').replace(queryParameters: queryParams);
      
      print('Fetching staff from: $uri');
      final response = await http.get(uri, headers: headers);
      
      print('Staff fetch response status: ${response.statusCode}');
      print('Staff fetch response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Staff.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch staff: ${response.body}');
      }
    } catch (e) {
      print('Error fetching staff: $e');
      throw Exception('Failed to fetch staff: $e');
    }
  }

  // Fetch staff member by ID
  Future<Staff> fetchStaffById(String staffId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/staff/$staffId'),
        headers: headers,
      );

      print('Fetch staff by ID response status: ${response.statusCode}');
      print('Fetch staff by ID response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Staff.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch staff member: ${response.body}');
      }
    } catch (e) {
      print('Error fetching staff by ID: $e');
      throw Exception('Failed to fetch staff member: $e');
    }
  }

  // Create new staff member
  Future<Staff> createStaff(Staff staff, String password) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode(staff.toCreateJson(password: password));
      
      print('Creating staff with body: $body');
      final response = await http.post(
        Uri.parse('$baseUrl/staff'),
        headers: headers,
        body: body,
      );

      print('Create staff response status: ${response.statusCode}');
      print('Create staff response body: ${response.body}');

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Staff.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create staff member');
      }
    } catch (e) {
      print('Error creating staff: $e');
      throw Exception('Failed to create staff member: $e');
    }
  }

  // Update staff member
  Future<Staff> updateStaff(String staffId, Staff staff) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode(staff.toJson());
      
      print('Updating staff $staffId with body: $body');
      final response = await http.put(
        Uri.parse('$baseUrl/staff/$staffId'),
        headers: headers,
        body: body,
      );

      print('Update staff response status: ${response.statusCode}');
      print('Update staff response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Staff.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update staff member');
      }
    } catch (e) {
      print('Error updating staff: $e');
      throw Exception('Failed to update staff member: $e');
    }
  }

  // Update staff status
  Future<Staff> updateStaffStatus(String staffId, String status) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({'status': status});
      
      print('Updating staff $staffId status to: $status');
      final response = await http.patch(
        Uri.parse('$baseUrl/staff/$staffId/status'),
        headers: headers,
        body: body,
      );

      print('Update staff status response status: ${response.statusCode}');
      print('Update staff status response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Staff.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update staff status');
      }
    } catch (e) {
      print('Error updating staff status: $e');
      throw Exception('Failed to update staff status: $e');
    }
  }

  // Reset staff password
  Future<void> resetStaffPassword(String staffId, String newPassword) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({'new_password': newPassword});
      
      print('Resetting password for staff $staffId');
      final response = await http.patch(
        Uri.parse('$baseUrl/staff/$staffId/reset-password'),
        headers: headers,
        body: body,
      );

      print('Reset password response status: ${response.statusCode}');
      print('Reset password response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      print('Error resetting password: $e');
      throw Exception('Failed to reset password: $e');
    }
  }

  // Delete (deactivate) staff member
  Future<void> deleteStaff(String staffId) async {
    try {
      final headers = await _getHeaders();
      
      print('Deleting staff $staffId');
      final response = await http.delete(
        Uri.parse('$baseUrl/staff/$staffId'),
        headers: headers,
      );

      print('Delete staff response status: ${response.statusCode}');
      print('Delete staff response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete staff member');
      }
    } catch (e) {
      print('Error deleting staff: $e');
      throw Exception('Failed to delete staff member: $e');
    }
  }

  // Get staff statistics
  Future<StaffStats> getStaffStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/staff/stats'),
        headers: headers,
      );

      print('Staff stats response status: ${response.statusCode}');
      print('Staff stats response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return StaffStats.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch staff statistics: ${response.body}');
      }
    } catch (e) {
      print('Error fetching staff stats: $e');
      throw Exception('Failed to fetch staff statistics: $e');
    }
  }
} 