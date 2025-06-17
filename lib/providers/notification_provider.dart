
// lib/providers/notification_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => n.isUnread).length;

  void startPolling() {
    stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      loadNotifications();
    });
    // Load immediately
    loadNotifications();
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _notificationService.getNotifications();
      
      if (response.success && response.data != null) {
        _notifications = response.data!;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to load notifications: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await _notificationService.markAsRead(notificationId);
      
      if (response.success) {
        // Update local notification status
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: _notifications[index].id,
            userId: _notifications[index].userId,
            title: _notifications[index].title,
            message: _notifications[index].message,
            status: 'read',
            createdAt: _notifications[index].createdAt,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
      }
    } catch (e) {
      // Handle error silently for UX
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}