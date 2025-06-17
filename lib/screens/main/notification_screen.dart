import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_utils.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    // Mark all as read (you can implement this feature)
                    for (var notification in notificationProvider.notifications) {
                      if (notification.isUnread) {
                        notificationProvider.markAsRead(notification.id);
                      }
                    }
                  },
                  child: const Text('Tandai Semua'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    notificationProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => notificationProvider.loadNotifications(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (notificationProvider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInUp(
                    child: Icon(
                      Icons.notifications_none_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Belum ada notifikasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      'Notifikasi akan muncul di sini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => notificationProvider.loadNotifications(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                
                return FadeInUp(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  child: GestureDetector(
                    onTap: () {
                      if (notification.isUnread) {
                        notificationProvider.markAsRead(notification.id);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notification.isUnread ? Colors.blue[50] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: notification.isUnread 
                            ? Border.all(color: Colors.blue[200]!, width: 1)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: notification.isUnread 
                                  ? AppTheme.primaryColor 
                                  : Colors.grey[400],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              _getNotificationIcon(notification.title),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: notification.isUnread 
                                              ? FontWeight.bold 
                                              : FontWeight.w600,
                                          color: notification.isUnread 
                                              ? Colors.black87 
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    if (notification.isUnread)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                
                                const SizedBox(height: 4),
                                
                                Text(
                                  notification.message,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    height: 1.3,
                                  ),
                                ),
                                
                                const SizedBox(height: 6),
                                
                                Text(
                                  AppUtils.formatDateTime(notification.createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String title) {
    if (title.toLowerCase().contains('donasi')) {
      return Icons.favorite;
    } else if (title.toLowerCase().contains('top') || title.toLowerCase().contains('saldo')) {
      return Icons.account_balance_wallet;
    } else {
      return Icons.info;
    }
  }
}