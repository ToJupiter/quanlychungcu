import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  final String _baseUrl = ApiConfig.baseUrl;
  static const String _tokenKey = 'auth_token';
  static const String _staffIdKey = 'staff_id';
  static const String _staffFullNameKey = 'staff_full_name';
  static const String _staffRoleKey = 'staff_role';


  Future<void> _saveAuthData(String token, String staffId, String fullName, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_staffIdKey, staffId);
    await prefs.setString(_staffFullNameKey, fullName);
    await prefs.setString(_staffRoleKey, role);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, String?>> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'staffId': prefs.getString(_staffIdKey),
      'fullName': prefs.getString(_staffFullNameKey),
      'role': prefs.getString(_staffRoleKey),
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_staffIdKey);
    await prefs.remove(_staffFullNameKey);
    await prefs.remove(_staffRoleKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<Map<String, dynamic>> loginStaff(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/staff/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      
      // Determine where the actual user data and token are located
      Map<String, dynamic>? authDataPayload;
      if (responseBody.containsKey('data') && responseBody['data'] is Map) {
        authDataPayload = responseBody['data'] as Map<String, dynamic>;
      } else {
        // If no 'data' key, or it's not a map, assume the main body is the payload
        // This can happen if backend sends { "token": "...", "staff": { ... } } directly
        authDataPayload = responseBody; 
      }

      final String? token = authDataPayload['token'] as String?;
      final Map<String, dynamic>? userData = authDataPayload['user'] as Map<String, dynamic>?;

      if (token != null && userData != null) {
        final dynamic staffIdRaw = userData['staff_id'];
        final String? staffFullName = userData['name'] as String?;
        final String? staffEmail = userData['email'] as String?;
        final String? staffRole = userData['role'] as String?;

        if (staffIdRaw == null) {
          throw Exception('Login successful, but staff ID is missing in the response.');
        }

        await _saveAuthData(
          token,
          staffIdRaw.toString(), // Ensure ID is string
          staffFullName ?? 'N/A', // Provide default if null
          staffRole ?? 'staff'   // Provide default if null
        );
        // Return the part of the payload that contains token and staff info
        // This is useful for the UI to potentially display staff name, etc.
        return authDataPayload; 
      } else {
        String missingParts = "";
        if (token == null) missingParts += "token";
        if (userData == null) missingParts += (missingParts.isEmpty ? "" : ", ") + "user object";
        
        throw Exception('Login successful, but response data is malformed. Missing: $missingParts. Response: ${response.body}');
      }
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to login: ${errorBody['message'] ?? response.reasonPhrase}');
      } catch (e) {
        // If error response is not JSON or doesn't have message
        throw Exception('Failed to login. Status: ${response.statusCode}, Body: ${response.body}');
      }
    }
  }

  Future<Map<String, dynamic>> registerStaff(String fullName, String email, String password, String role) async {
    String? token = await getToken(); 
    if (token == null) {
      // This case might be for public registration if allowed, or error if admin-only
      // For now, let's assume admin needs to be logged in to register other staff
      throw Exception('Authentication required to register new staff. Please ensure an admin is logged in.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/staff/register'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'role': role, 
      }),
    );

    if (response.statusCode == 201) {
      // Backend might return the created staff object or just a success message.
      // For consistency, if it returns the staff object, wrap it in 'data'.
      final responseBody = jsonDecode(response.body);
      return responseBody['data'] ?? responseBody; 
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to register staff: ${errorBody['message'] ?? response.reasonPhrase}');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final response = await http.put( // Using PUT as it's an update operation
      Uri.parse('$_baseUrl/auth/staff/change-password'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 204) { // 204 No Content also success
      // Password changed successfully
      return;
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to change password: ${errorBody['message'] ?? response.reasonPhrase}');
      } catch(e) {
        // If body is not JSON or empty for some reason
         throw Exception('Failed to change password. Status code: ${response.statusCode}');
      }
    }
  }
} 