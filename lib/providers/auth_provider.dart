import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Check if user is already logged in
  Future<bool> checkAuthStatus() async {
    try {
      final token = await _apiService.getToken();
      if (token != null) {
        // TODO: Validate token with backend
        // For now, we'll assume token is valid
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.login(email, password);

      // Set _currentUser to a valid User object so HomeScreen can render
      _currentUser = User(
        id: response['user_id'],
        email: email,
        fullName: '', // You can fetch the full profile later if needed
        phone: '',
        address: '',
        userType: response['user_type'] ?? '',
        createdAt: DateTime.now(),
      );

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Register User
  Future<bool> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String address,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.registerUser(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        address: address,
      );

      _currentUser = User.fromJson(response['user']);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Register Worker
  Future<bool> registerWorker({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String address,
    required String skills,
    required double hourlyRate,
    required bool lookingForWork,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.registerWorker(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        address: address,
        skills: skills,
        hourlyRate: hourlyRate,
        lookingForWork: lookingForWork,
      );

      _currentUser = Worker.fromJson(response['user']);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.clearStoredData();
      _currentUser = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.updateWorkerProfile(data);

      if (_currentUser is Worker) {
        _currentUser = Worker.fromJson(response);
      } else {
        _currentUser = User.fromJson(response);
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Refresh user profile from backend
  Future<bool> refreshUserProfile() async {
    if (_currentUser == null) return false;

    try {
      final userProfile = await _apiService.getUserProfile();

      if (_currentUser is Worker) {
        _currentUser = Worker.fromJson(userProfile);
      } else {
        _currentUser = User.fromJson(userProfile);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
