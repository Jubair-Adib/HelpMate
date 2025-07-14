import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/worker.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String apiUrl = '$baseUrl/api';

  // Shared preferences key
  static const String tokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  static const String userIdKey = 'user_id';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Store token
  Future<void> storeToken(String token, String userType, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userTypeKey, userType);
    await prefs.setInt(userIdKey, userId);
  }

  // Clear stored data
  Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userTypeKey);
    await prefs.remove(userIdKey);
  }

  // Get headers with authentication
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generic HTTP methods
  Future<http.Response> _get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(Uri.parse('$apiUrl$endpoint'), headers: headers);
  }

  Future<http.Response> _post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$apiUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> _put(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse('$apiUrl$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> _delete(String endpoint) async {
    final headers = await _getHeaders();
    return await http.delete(Uri.parse('$apiUrl$endpoint'), headers: headers);
  }

  // Authentication APIs
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/v1/auth/login/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        await storeToken(
          data['access_token'],
          data['user_type'],
          data['user_id'],
        );
        return data;
      } else {
        // Try to parse error message, or return a default error
        String errorMsg = 'Login failed';
        try {
          final errorData =
              response.body.isNotEmpty ? jsonDecode(response.body) : null;
          if (errorData is Map && errorData['detail'] != null) {
            errorMsg = errorData['detail'].toString();
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/v1/auth/register/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
          'address': address,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await storeToken(data['access_token'], 'user', data['user_id']);
        return data;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> registerWorker({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String address,
    required String skills,
    required double hourlyRate,
    required bool lookingForWork,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/v1/auth/register/worker'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
          'address': address,
          'skills': skills,
          'hourly_rate': hourlyRate,
          'looking_for_work': lookingForWork,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await storeToken(data['access_token'], 'worker', data['user_id']);
        return data;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Categories APIs
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _get('/v1/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch categories: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Workers APIs
  Future<List<Worker>> getWorkers({String? categoryId}) async {
    try {
      String endpoint = '/v1/workers';
      if (categoryId != null) {
        endpoint += '?category_id=$categoryId';
      }
      final response = await _get(endpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Worker.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch workers: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Worker> getWorkerProfile(int workerId) async {
    try {
      final response = await _get('/v1/workers/$workerId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Worker.fromJson(data);
      } else {
        throw Exception('Failed to fetch worker profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> updateWorkerProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(userIdKey);
      if (userId == null) throw Exception('User not authenticated');

      final response = await _put('/v1/workers/$userId', data);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Services APIs
  Future<List<Map<String, dynamic>>> getServices({int? workerId}) async {
    try {
      String endpoint = '/v1/services';
      if (workerId != null) {
        endpoint += '?worker_id=$workerId';
      }
      final response = await _get(endpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch services: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> createService(Map<String, dynamic> data) async {
    try {
      final response = await _post('/v1/services', data);
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create service: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> updateService(
    int serviceId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _put('/v1/services/$serviceId', data);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update service: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteService(int serviceId) async {
    try {
      final response = await _delete('/v1/services/$serviceId');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete service: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Orders APIs
  Future<List<Map<String, dynamic>>> getOrders({String? status}) async {
    try {
      String endpoint = '/v1/orders';
      if (status != null) {
        endpoint += '?status=$status';
      }
      final response = await _get(endpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch orders: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _post('/v1/orders/', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // Try to parse error message from response
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData['detail'] != null) {
            throw Exception(errorData['detail']);
          }
        } catch (_) {}
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    int orderId,
    String status,
  ) async {
    try {
      final response = await _put('/v1/orders/$orderId/status', {
        'status': status,
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update order status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Reviews APIs
  Future<List<Map<String, dynamic>>> getWorkerReviews(int workerId) async {
    try {
      final response = await _get('/v1/workers/$workerId/reviews');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch reviews: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> createReview(Map<String, dynamic> data) async {
    try {
      final response = await _post('/v1/reviews', data);
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create review: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // User Profile APIs
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _get('/v1/auth/user/profile');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _put('/v1/auth/user/profile', data);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update user profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Chat APIs
  Future<Map<String, dynamic>> createChat(int workerId) async {
    try {
      final response = await _post('/v1/chat/', {'worker_id': workerId});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create chat: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserChats() async {
    try {
      final response = await _get('/v1/chat');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch chats: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getChat(int chatId) async {
    try {
      final response = await _get('/v1/chat/$chatId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch chat: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChatMessages(int chatId) async {
    try {
      final response = await _get('/v1/chat/$chatId/messages');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch messages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessage(int chatId, String content) async {
    try {
      final response = await _post('/v1/chat/$chatId/messages', {
        'content': content,
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Favorites APIs
  Future<Map<String, dynamic>> addToFavorites(int workerId) async {
    try {
      final response = await _post('/v1/favorites/', {'worker_id': workerId});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add to favorites: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> removeFromFavorites(int workerId) async {
    try {
      final response = await _delete('/v1/favorites/$workerId');
      if (response.statusCode != 200) {
        throw Exception('Failed to remove from favorites: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final response = await _get('/v1/favorites/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch favorites: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> checkFavorite(int workerId) async {
    try {
      final response = await _get('/v1/favorites/check/$workerId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_favorite'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Review creation for completed orders
  Future<Map<String, dynamic>> createOrderReview(
    int orderId,
    Map<String, dynamic> reviewData,
  ) async {
    try {
      final response = await _post('/v1/orders/$orderId/review', reviewData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create review: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
