import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';

class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._internal();
  ApiService._internal();

  String? _token;

  // ✅ FIX: Better token loading
  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      
      if (ApiConstants.isDebugMode && _token != null) {
        developer.log('🔑 Token loaded: ${_token!.substring(0, 20)}...');
      } else if (ApiConstants.isDebugMode) {
        developer.log('❌ No token found in storage');
      }
    } catch (e) {
      developer.log('❌ Error loading token: $e');
      _token = null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      _token = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      
      if (ApiConstants.isDebugMode) {
        developer.log('✅ Token saved: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      developer.log('❌ Error saving token: $e');
    }
  }

  Future<void> removeToken() async {
    try {
      _token = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      
      if (ApiConstants.isDebugMode) {
        developer.log('🗑️ Token removed');
      }
    } catch (e) {
      developer.log('❌ Error removing token: $e');
    }
  }

  // ✅ FIX: Better headers with token validation
  Future<Map<String, String>> get _headers async {
    await _loadToken(); // ✅ Always load fresh token
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
      
      if (ApiConstants.isDebugMode) {
        developer.log('🔑 Using token: ${_token!.substring(0, 20)}...');
      }
    } else {
      if (ApiConstants.isDebugMode) {
        developer.log('⚠️ No token available for request');
      }
    }
    
    return headers;
  }

  // ✅ FIX: Handle 401 responses properly
  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
    String endpoint,
  ) async {
    if (ApiConstants.isDebugMode) {
      developer.log('🌐 API Response from $endpoint');
      developer.log('📊 Status Code: ${response.statusCode}');
      developer.log('📋 Response Body: ${response.body}');
    }

    // ✅ Handle 401 Unauthorized
    if (response.statusCode == 401) {
      if (ApiConstants.isDebugMode) {
        developer.log('🚨 401 Unauthorized - Token expired or invalid');
      }
      
      // Clear invalid token
      await removeToken();
      
      return ApiResponse<T>(
        success: false,
        message: 'Session expired. Please login again.',
      );
    }

    try {
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>(
          success: responseData['success'] ?? true,
          message: responseData['message'] ?? 'Success',
          data: fromJson != null && responseData['data'] != null 
              ? fromJson(responseData['data']) 
              : responseData['data'],
        );
      } else {
        return ApiResponse<T>(
          success: false,
          message: responseData['message'] ?? 'Error occurred',
          errors: responseData['errors'] != null 
              ? List<String>.from(responseData['errors']) 
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> body, {
    T Function(dynamic)? fromJson,
  }) async {
    final headers = await _headers; // ✅ Use async headers

    if (ApiConstants.isDebugMode) {
      developer.log('🚀 POST Request to: $endpoint');
      developer.log('📤 Request Body: ${json.encode(body)}');
      developer.log('🔑 Headers: $headers');
    }

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw SocketException('Connection timeout');
        },
      );
      
      return _handleResponse<T>(response, fromJson, endpoint);
    } on SocketException catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Tidak dapat terhubung ke server: $e',
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Connection failed: $e',
      );
    }
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
    Map<String, String>? queryParams,
  }) async {
    final headers = await _headers; // ✅ Use async headers
    
    Uri uri = Uri.parse(endpoint);
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    if (ApiConstants.isDebugMode) {
      developer.log('📡 GET Request to: $uri');
      developer.log('🔑 Headers: $headers');
    }

    try {
      final response = await http.get(uri, headers: headers);
      return _handleResponse<T>(response, fromJson, endpoint);
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ✅ NEW: Method to check if user is authenticated
  Future<bool> isAuthenticated() async {
    await _loadToken();
    return _token != null && _token!.isNotEmpty;
  }

  // ✅ NEW: Get current token (for debugging)
  Future<String?> getCurrentToken() async {
    await _loadToken();
    return _token;
  }

  Future testConnection() async {}
}