import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/worker.dart' as worker_models;

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _user;
  worker_models.Worker? _worker;
  String? _userType; // 'user' or 'worker'
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  worker_models.Worker? get worker => _worker;
  String? get userType => _userType;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null || _worker != null;

  /// Returns the currently logged-in user or worker, depending on userType
  Object? get currentUser => _userType == 'worker' ? _worker : _user;

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
  Future<bool> login(
    String email,
    String password, {
    required String userType,
  }) async {
    _setLoading(true);
    _clearError();
    _userType = userType;
    try {
      final response = await _apiService.login(
        email,
        password,
        userType: userType,
      );
      // Fetch full profile after login
      if (userType == 'worker') {
        final workerProfile = await _apiService.getWorkerProfile();
        _worker = worker_models.Worker.fromJson(workerProfile);
        _user = null;
      } else {
        final userProfile = await _apiService.getUserProfile();
        _user = User.fromJson(userProfile);
        _worker = null;
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
    _userType = 'user';
    try {
      final response = await _apiService.registerUser(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        address: address,
      );
      // If response looks like a user object, treat as success
      if (response.containsKey('email')) {
        _user = User.fromJson(response);
        _worker = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed: Unexpected response');
        _setLoading(false);
        notifyListeners();
        return false;
      }
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
    required List<String> skills,
    required double hourlyRate,
    required bool lookingForWork,
    int? categoryId,
  }) async {
    _setLoading(true);
    _clearError();
    _userType = 'worker';
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
        categoryId: categoryId,
      );
      if (response.containsKey('email')) {
        _worker = worker_models.Worker.fromJson(response);
        _user = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed: Unexpected response');
        _setLoading(false);
        notifyListeners();
        return false;
      }
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
      await _apiService.logout();
      _user = null;
      _worker = null;
      _userType = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_user == null && _worker == null) return false;

    _setLoading(true);
    _clearError();

    try {
      Map<String, dynamic> response;
      if (_userType == 'worker') {
        response = await _apiService.updateWorkerProfile(data);
      } else {
        response = await _apiService.updateUserProfile(data);
      }

      if (_worker != null) {
        _worker = worker_models.Worker.fromJson(response);
      } else {
        _user = User.fromJson(response);
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
    if (_user == null && _worker == null) return false;

    try {
      Map<String, dynamic> userProfile;
      if (_userType == 'worker') {
        userProfile = await _apiService.getWorkerProfile();
      } else {
        userProfile = await _apiService.getUserProfile();
      }

      if (_worker != null) {
        _worker = worker_models.Worker.fromJson(userProfile);
      } else {
        _user = User.fromJson(userProfile);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  // Refresh authentication and user type from token/profile
  Future<bool> refreshAuthAndUserType() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        await logout();
        return false;
      }
      // Try worker profile first
      try {
        final workerProfile = await _apiService.getWorkerProfile();
        _worker = worker_models.Worker.fromJson(workerProfile);
        _user = null;
        _userType = 'worker';
        notifyListeners();
        return true;
      } catch (_) {}
      // Try user profile
      try {
        final userProfile = await _apiService.getUserProfile();
        _user = User.fromJson(userProfile);
        _worker = null;
        _userType = 'user';
        notifyListeners();
        return true;
      } catch (_) {}
      // If neither, logout
      await logout();
      return false;
    } catch (_) {
      await logout();
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
