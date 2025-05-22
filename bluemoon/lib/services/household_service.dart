import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/household_model.dart';
import '../models/resident_model.dart';
import '../models/vehicle_model.dart';
import 'auth_service.dart'; // For token

// This class will hold all data for the household details view
class HouseholdDetailsData {
  final Household householdInfo;
  final List<Resident> residents;
  final List<Vehicle> vehicles;

  HouseholdDetailsData({
    required this.householdInfo,
    required this.residents,
    required this.vehicles,
  });

  factory HouseholdDetailsData.fromJson(Map<String, dynamic> json) {
    // Handle the format from our backend which has household fields at top level
    // with residents and vehicles arrays
    try {
      // Extract main household data
      Household household = Household.fromJson(json);
      
      // Extract residents
      List<Resident> residentList = [];
      if (json['residents'] != null && json['residents'] is List) {
        residentList = (json['residents'] as List)
            .map((r) => Resident.fromJson(r as Map<String, dynamic>))
            .toList();
      }
      
      // Extract vehicles
      List<Vehicle> vehicleList = [];
      if (json['vehicles'] != null && json['vehicles'] is List) {
        vehicleList = (json['vehicles'] as List)
            .map((v) => Vehicle.fromJson(v as Map<String, dynamic>))
            .toList();
      }
      
      return HouseholdDetailsData(
        householdInfo: household,
        residents: residentList,
        vehicles: vehicleList,
      );
    } catch (e) {
      print('Error parsing HouseholdDetailsData: $e');
      print('JSON structure: ${json.keys.join(', ')}');
      throw Exception('Failed to parse household details: $e');
    }
  }
}

class HouseholdService {
  final String _baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _authService.getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<HouseholdDetailsData> fetchHouseholdDetails(String householdId) async {
    final String url = '$_baseUrl/management/households/$householdId/details';
    try {
      final response = await http.get(Uri.parse(url), headers: await _getHeaders());
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return HouseholdDetailsData.fromJson(responseData);
      } else {
        print('Failed to load household details for $householdId: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load household details (${response.statusCode})');
      }
    } catch (e) {
      print('HouseholdService fetchHouseholdDetails Error: $e');
      throw Exception('Failed to fetch household details: $e');
    }
  }

  // --- Resident CRUD ---
  Future<Resident> addResident(String householdId, Map<String, dynamic> residentData) async {
    final String url = '$_baseUrl/management/households/$householdId/residents';
    try {
      final response = await http.post(Uri.parse(url), headers: await _getHeaders(), body: jsonEncode(residentData));
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Resident.fromJson(responseData as Map<String, dynamic>);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add resident (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to add resident: $e');
    }
  }

  Future<Resident> updateResident(String residentId, Map<String, dynamic> residentData) async {
    final String url = '$_baseUrl/management/residents/$residentId';
    try {
      final response = await http.put(Uri.parse(url), headers: await _getHeaders(), body: jsonEncode(residentData));
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Resident.fromJson(responseData as Map<String, dynamic>);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update resident (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to update resident: $e');
    }
  }

  Future<void> deleteResident(String residentId) async {
    final String url = '$_baseUrl/management/residents/$residentId';
    try {
      final response = await http.delete(Uri.parse(url), headers: await _getHeaders());
      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Success
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to delete resident (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to delete resident: $e');
    }
  }

  // --- Vehicle CRUD ---
  Future<Vehicle> addVehicle(String householdId, Map<String, dynamic> vehicleData) async {
    final String url = '$_baseUrl/management/households/$householdId/vehicles';
    try {
      final response = await http.post(Uri.parse(url), headers: await _getHeaders(), body: jsonEncode(vehicleData));
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Vehicle.fromJson(responseData as Map<String, dynamic>);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add vehicle (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  Future<Vehicle> updateVehicle(String vehicleId, Map<String, dynamic> vehicleData) async {
    final String url = '$_baseUrl/management/vehicles/$vehicleId';
    try {
      final response = await http.put(Uri.parse(url), headers: await _getHeaders(), body: jsonEncode(vehicleData));
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Vehicle.fromJson(responseData as Map<String, dynamic>);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update vehicle (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    final String url = '$_baseUrl/management/vehicles/$vehicleId';
    try {
      final response = await http.delete(Uri.parse(url), headers: await _getHeaders());
      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Success
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to delete vehicle (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  // Fetch basic household list
  Future<List<Household>> fetchHouseholds() async {
    final String url = '$_baseUrl/management/households';
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        List<dynamic> householdList;
        if (responseBody is Map && responseBody.containsKey('data') && responseBody['data'] is List) {
          householdList = responseBody['data'] as List<dynamic>;
        } else if (responseBody is List) {
          householdList = responseBody;
        } else {
          print('Unexpected household list format: $responseBody');
          throw Exception('Unexpected response format for households');
        }
        List<Household> households = householdList
          .map((dynamic item) => Household.fromJson(item as Map<String, dynamic>))
          .where((h) => h.id.isNotEmpty && h.apartmentId.isNotEmpty && h.headResidentName.isNotEmpty)
          .toList();
        return households;
      } else {
        print('Failed to load households: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load households (${response.statusCode})');
      }
    } catch (e) {
      print('HouseholdService fetchHouseholds Error: $e');
      throw Exception('Failed to fetch households: $e');
    }
  }

  Future<Household> createHousehold(Map<String, dynamic> householdData) async {
    final String url = '$_baseUrl/management/households';
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(householdData),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Household.fromJson(responseData as Map<String, dynamic>);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to create household (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to create household: $e');
    }
  }

  Future<int> getResidentsCount() async {
    String? token = await _authService.getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$_baseUrl/management/residents/count'), // Assuming this endpoint exists
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      // Assuming the backend returns something like: { "data": { "count": 150 } } or { "count": 150 }
      if (body['data'] != null && body['data']['count'] != null) {
        return body['data']['count'] as int;
      } else if (body['count'] != null) {
        return body['count'] as int;
      }
      throw Exception('Failed to parse residents count from response');
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to load residents count: ${errorBody['message'] ?? response.reasonPhrase}');
    }
  }
} 