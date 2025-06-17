import '../models/user_model.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService.instance;

  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    return await _apiService.post<Map<String, dynamic>>(
      ApiConstants.login,
      {
        'email': email,
        'password': password,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _apiService.post<Map<String, dynamic>>(
      ApiConstants.register,
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<ApiResponse<dynamic>> logout() async {
    return await _apiService.post<dynamic>(ApiConstants.logout, {});
  }

  Future<ApiResponse<User>> getCurrentUser() async {
    return await _apiService.get<User>(
      ApiConstants.user,
      fromJson: (data) => User.fromJson(data),
    );
  }
}