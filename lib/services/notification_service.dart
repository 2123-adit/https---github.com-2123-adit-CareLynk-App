import 'dart:developer' as developer;
import '../models/notification_model.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService.instance;

  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    try {
      developer.log('Fetching notifications from API', name: 'NotificationService');
      
      return await _apiService.get<List<NotificationModel>>(
        ApiConstants.notifications,
        fromJson: (data) {
          developer.log('Raw API data: $data', name: 'NotificationService');
          
          if (data == null) {
            developer.log('API returned null data', name: 'NotificationService');
            return <NotificationModel>[];
          }
          
          if (data is! List) {
            developer.log('API data is not a List: ${data.runtimeType}', name: 'NotificationService');
            throw Exception('Expected List but got ${data.runtimeType}');
          }
          
          try {
            final notifications = data.map((item) {
              developer.log('Processing notification item: $item', name: 'NotificationService');
              return NotificationModel.fromJson(item as Map<String, dynamic>);
            }).toList();
            
            developer.log('Successfully parsed ${notifications.length} notifications', 
                         name: 'NotificationService');
            return notifications;
          } catch (e, stackTrace) {
            developer.log('Error parsing notifications: $e', 
                         name: 'NotificationService', 
                         error: e, 
                         stackTrace: stackTrace);
            rethrow;
          }
        },
      );
    } catch (e, stackTrace) {
      developer.log('Exception in getNotifications: $e', 
                   name: 'NotificationService', 
                   error: e, 
                   stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<ApiResponse<dynamic>> markAsRead(int notificationId) async {
    try {
      developer.log('Marking notification $notificationId as read', name: 'NotificationService');
      
      return await _apiService.post<dynamic>(
        ApiConstants.markAsRead,
        {'notification_id': notificationId},
      );
    } catch (e, stackTrace) {
      developer.log('Exception in markAsRead: $e', 
                   name: 'NotificationService', 
                   error: e, 
                   stackTrace: stackTrace);
      rethrow;
    }
  }
}