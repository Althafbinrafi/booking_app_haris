import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://booking-backend-0b9z.onrender.com';
  static final http.Client _client = http.Client();

  // Get stored token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // Save tokens
  static Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  // Save user ID
  static Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  // Clear tokens (logout)
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userId');
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw ApiException(
          message: responseData['message'] ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }

  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$baseUrl$endpoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final headers = <String, String>{};

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      final response = await _client.get(uri, headers: headers);
      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw ApiException(
          message: responseData['message'] ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }

  // PATCH request
  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      final response = await _client.patch(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw ApiException(
          message: responseData['message'] ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }

  // Auth: Send OTP
  static Future<String> sendOtp(String phone) async {
    final response = await post('/auth/send-otp', {'phone': phone});
    return response['message'] ?? 'OTP sent successfully';
  }

  // Auth: Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String otp,
  ) async {
    final response = await post('/auth/verify-otp', {
      'phone': phone,
      'otp': otp,
    });

    // Save tokens
    await _saveTokens(
      response['tokens']['accessToken'],
      response['tokens']['refreshToken'],
    );
    await _saveUserId(response['user']['id']);

    // Save user data to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhone', phone);
    if (response['user']['name'] != null) {
      await prefs.setString('userName', response['user']['name']);
    }
    if (response['user']['city'] != null) {
      await prefs.setString('userCity', response['user']['city']);
    }
    if (response['user']['email'] != null) {
      await prefs.setString('userEmail', response['user']['email']);
    }

    return response['user'];
  }

  // Auth: Register/Complete Profile
  static Future<Map<String, dynamic>> register({
    required String name,
    String? email,
    String? city,
  }) async {
    final response = await post('/auth/register', {
      'name': name,
      if (email != null) 'email': email,
      if (city != null) 'city': city,
    }, requiresAuth: true);

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    if (city != null) {
      await prefs.setString('userCity', city);
    }
    if (email != null) {
      await prefs.setString('userEmail', email);
    }

    return response['user'];
  }

  // Professional: Apply
  static Future<Map<String, dynamic>> applyProfessional({
    required String title,
    required String professionType,
    required String categorySlug,
    required String about,
    required String city,
    required String consultationMode,
    required int baseFee,
    required int yearsExperience,
    String? address,
    List<String>? tags,
  }) async {
    final response = await post('/professional/apply', {
      'title': title,
      'professionType': professionType,
      'categorySlug': categorySlug,
      'about': about,
      'city': city,
      'consultationMode': consultationMode,
      'baseFee': baseFee,
      'yearsExperience': yearsExperience,
      if (address != null) 'address': address,
      if (tags != null) 'tags': tags,
    }, requiresAuth: true);

    return response;
  }

  // Professional: Get My Profile
  static Future<Map<String, dynamic>?> getMyProfessionalProfile() async {
    try {
      final response = await get('/professional/me', requiresAuth: true);
      return response['data'];
    } catch (e) {
      return null;
    }
  }

  // Professional: Search
  static Future<List<dynamic>> searchProfessionals({
    String? city,
    String? professionType,
    String? q,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (city != null && city != 'Select City') 'city': city,
      if (professionType != null) 'professionType': professionType,
      if (q != null && q.isNotEmpty) 'q': q,
    };

    final response = await get('/professional', queryParams: queryParams);
    return response['data'] ?? [];
  }

  // Professional: Get Details
  static Future<Map<String, dynamic>> getProfessionalDetails(String id) async {
    final response = await get('/professional/$id');
    return response['data'];
  }

  // Bookings: Create
  static Future<Map<String, dynamic>> createBooking({
    required String professionalId,
    required DateTime scheduledFor,
    String? notes,
  }) async {
    final response = await post('/bookings', {
      'professionalId': professionalId,
      'scheduledFor': scheduledFor.toIso8601String(),
      if (notes != null) 'notes': notes,
    }, requiresAuth: true);

    return response['data'];
  }

  // Bookings: Get My Bookings
  static Future<List<dynamic>> getMyBookings() async {
    final response = await get('/bookings/me', requiresAuth: true);
    return response['data'] ?? [];
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}
