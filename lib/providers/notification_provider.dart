import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import 'auth_provider.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationProvider(this.authProvider);

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = authProvider.currentUser;
      if (user == null) {
        _notifications = [];
        _isLoading = false;
        notifyListeners();
        return;
      }
      String url = '';
      if (authProvider.userType == 'user') {
        url = '/v1/notifications/user';
      } else if (authProvider.userType == 'worker') {
        url = '/v1/notifications/worker';
      } else {
        _notifications = [];
        _isLoading = false;
        notifyListeners();
        return;
      }
      final headers = await ApiService().getHeaders();
      final response = await http.get(
        Uri.parse(ApiService.apiUrl + url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _notifications =
            data.map((n) => NotificationModel.fromJson(n)).toList();
      } else {
        _error = 'Failed to load notifications';
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final user = authProvider.currentUser;
      if (user == null) return;
      String url = '/v1/notifications/$notificationId/read';
      final headers = await ApiService().getHeaders();
      final response = await http.put(
        Uri.parse(ApiService.apiUrl + url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        _notifications =
            _notifications.map((n) {
              if (n.id == notificationId) {
                return NotificationModel(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  message: n.message,
                  isRead: true,
                  createdAt: n.createdAt,
                );
              }
              return n;
            }).toList();
        notifyListeners();
      }
    } catch (e) {
      // Ignore error for now
    }
  }
}
