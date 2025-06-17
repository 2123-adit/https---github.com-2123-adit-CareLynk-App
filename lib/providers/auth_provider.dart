import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _lastError;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get lastError => _lastError;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await ApiService.instance.isAuthenticated();

      if (hasToken) {
        final response = await _authService.getCurrentUser();
        if (response.success && response.data != null) {
          _user = response.data;
          _isAuthenticated = true;
          if (ApiConstants.isDebugMode) {
            developer.log('✅ Auth check successful: ${_user!.name}');
          }
        } else {
          await _clearUserData();
          if (ApiConstants.isDebugMode) {
            developer.log('❌ Token invalid, clearing auth data');
          }
        }
      } else {
        await _clearUserData();
        if (ApiConstants.isDebugMode) {
          developer.log('❌ No token found');
        }
      }
    } catch (e) {
      await _clearUserData();
      if (ApiConstants.isDebugMode) {
        developer.log('❌ Auth check failed: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      if (response.success && response.data != null) {
        final token = response.data!['token'];
        final userData = response.data!['user'];

        await ApiService.instance.saveToken(token);
        _user = User.fromJson(userData);
        _isAuthenticated = true;

        if (ApiConstants.isDebugMode) {
          developer.log('✅ Login successful: ${_user!.name}');
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _lastError = response.message;
        if (ApiConstants.isDebugMode) {
          developer.log('❌ Login failed: ${response.message}');
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _lastError = 'Error: $e';
      if (ApiConstants.isDebugMode) {
        developer.log('❌ Login error: $e');
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.success && response.data != null) {
        final token = response.data!['token'];
        final userData = response.data!['user'];

        await ApiService.instance.saveToken(token);
        _user = User.fromJson(userData);
        _isAuthenticated = true;

        if (ApiConstants.isDebugMode) {
          developer.log('✅ Registration successful: ${_user!.name}');
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _lastError = response.message;
        if (ApiConstants.isDebugMode) {
          developer.log('❌ Registration failed: ${response.message}');
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _lastError = 'Error: $e';
      if (ApiConstants.isDebugMode) {
        developer.log('❌ Registration error: $e');
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      if (ApiConstants.isDebugMode) {
        developer.log('🚪 Logout successful');
      }
    } catch (e) {
      developer.log('⚠️ Logout API failed: $e');
    }

    await _clearUserData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _clearUserData() async {
    await ApiService.instance.removeToken();
    _user = null;
    _isAuthenticated = false;
    _lastError = null;
  }

  void handleSessionExpired() {
    _clearUserData();
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (!_isAuthenticated) return;

    try {
      final response = await _authService.getCurrentUser();
      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
      }
    } catch (e) {
      developer.log('⚠️ Failed to refresh user: $e');
    }
  }

  void updateUserBalance(double newBalance) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        balance: newBalance,
        role: _user!.role,
        emailVerifiedAt: _user!.emailVerifiedAt,
        createdAt: _user!.createdAt,
        updatedAt: _user!.updatedAt,
      );
      notifyListeners();
    }
  }
}
