import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/apartment_model.dart';
import 'auth_service.dart'; // Import AuthService

class ApartmentService {
  final AuthService _authService = AuthService(); // Instantiate AuthService
  final String _baseUrl = ApiConfig.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _authService.getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Fetch all apartments
  // If pagination is added to backend, parameters like page, limit can be added here.
  Future<List<Apartment>> fetchApartments() async {
    final String url = '$_baseUrl/management/apartments';
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        // Expecting { "data": [ ...apartments... ], "total": count } or just [ ...apartments... ]
        final responseBody = jsonDecode(response.body);
        List<dynamic> apartmentList;
        if (responseBody is Map && responseBody.containsKey('data') && responseBody['data'] is List) {
          apartmentList = responseBody['data'] as List<dynamic>;
        } else if (responseBody is List) {
          apartmentList = responseBody;
        } else {
          throw Exception('Unexpected response format for apartments');
        }
        List<Apartment> apartments = apartmentList.map((dynamic item) => Apartment.fromJson(item as Map<String, dynamic>)).toList();
        return apartments;
      } else {
        print('Failed to load apartments: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load apartments (${response.statusCode})');
      }
    } catch (e) {
      print('ApartmentService fetchApartments Error: $e');
      throw Exception('Failed to fetch apartments: $e');
    }
  }

  // Method to get total apartment count (can be more efficient if backend has a dedicated endpoint)
  Future<int> getApartmentsCount() async {
    // This is not the most efficient way if the list is very large.
    // Ideally, the backend provides a count endpoint or includes count in fetchApartments metadata.
    final apartments = await fetchApartments(); 
    return apartments.length;
  }

  // Create a new apartment
  Future<Apartment> createApartment(Map<String, dynamic> apartmentData) async {
    final String url = '$_baseUrl/management/apartments';
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(apartmentData),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) { // 201 is typical for creation
        return Apartment.fromJson(responseData as Map<String, dynamic>);
      } else {
        print('Failed to create apartment: ${response.statusCode} ${response.body}');
        throw Exception(responseData['message'] ?? 'Failed to create apartment (${response.statusCode})');
      }
    } catch (e) {
      print('ApartmentService createApartment Error: $e');
      throw Exception('Failed to create apartment: $e');
    }
  }

  // Update an existing apartment
  Future<Apartment> updateApartment(String id, Map<String, dynamic> apartmentData) async {
    final String url = '$_baseUrl/management/apartments/$id';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(apartmentData),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Apartment.fromJson(responseData as Map<String, dynamic>);
      } else {
        print('Failed to update apartment: ${response.statusCode} ${response.body}');
        throw Exception(responseData['message'] ?? 'Failed to update apartment (${response.statusCode})');
      }
    } catch (e) {
      print('ApartmentService updateApartment Error: $e');
      throw Exception('Failed to update apartment: $e');
    }
  }

  // Delete an apartment
  Future<void> deleteApartment(String id) async {
    final String url = '$_baseUrl/management/apartments/$id';
    try {
      final response = await http.delete(Uri.parse(url), headers: await _getHeaders());
      if (response.statusCode == 200 || response.statusCode == 204) { // 204 means No Content, success for delete
        return; // Successfully deleted
      } else {
         final responseData = jsonDecode(response.body);
        print('Failed to delete apartment: ${response.statusCode} ${response.body}');
        throw Exception(responseData['message'] ?? 'Failed to delete apartment (${response.statusCode})');
      }
    } catch (e) {
      print('ApartmentService deleteApartment Error: $e');
      throw Exception('Failed to delete apartment: $e');
    }
  }
  
  // Fetch a single apartment by ID (if needed by ApartmentFormView for edit mode later)
  Future<Apartment> fetchApartmentById(String id) async {
    final String url = '$_baseUrl/management/apartments/$id';
    try {
      final response = await http.get(Uri.parse(url), headers: await _getHeaders());
      if (response.statusCode == 200) {
        return Apartment.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        print('Failed to load apartment $id: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load apartment $id (${response.statusCode})');
      }
    } catch (e) {
      print('ApartmentService fetchApartmentById Error: $e');
      throw Exception('Failed to fetch apartment $id: $e');
    }
  }
} 