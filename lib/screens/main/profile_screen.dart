import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import '../topup/topup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with Profile Info
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final user = authProvider.user;
                      return Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          Text(
                            user?.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Saldo: ${AppUtils.formatCurrency(user?.balance ?? 0)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Menu Items
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    FadeInLeft(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: _buildMenuItem(
                        context: context,
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Top Up Saldo',
                        subtitle: 'Tambah saldo untuk berdonasi',
                        color: AppTheme.successColor,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const TopupScreen()),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    FadeInLeft(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: _buildMenuItem(
                        context: context,
                        icon: Icons.volunteer_activism_outlined,
                        title: 'Riwayat Donasi',
                        subtitle: 'Lihat semua donasi yang telah diberikan',
                        color: AppTheme.primaryColor,
                        onTap: () {
                          // Navigate to history tab
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    FadeInLeft(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      child: _buildMenuItem(
                        context: context,
                        icon: Icons.notifications_outlined,
                        title: 'Notifikasi',
                        subtitle: 'Kelola notifikasi aplikasi',
                        color: AppTheme.warningColor,
                        onTap: () {
                          // Navigate to notification tab
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    FadeInLeft(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 500),
                      child: _buildMenuItem(
                        context: context,
                        icon: Icons.info_outline,
                        title: 'Tentang Aplikasi',
                        subtitle: 'Informasi tentang ${AppStrings.appName}',
                        color: Colors.blue,
                        onTap: () => _showAboutDialog(context),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 600),
                      child: _buildMenuItem(
                        context: context,
                        icon: Icons.logout_outlined,
                        title: 'Keluar',
                        subtitle: 'Keluar dari aplikasi',
                        color: AppTheme.errorColor,
                        onTap: () => _handleLogout(context), // ✅ Ganti method
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
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tentang Aplikasi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donation App',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Versi 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Aplikasi donasi yang memungkinkan Anda untuk berbagi kebaikan dengan mudah dan aman.',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 Donation App. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Handler logout yang benar
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // ✅ STEP 1: Close dialog
              Navigator.pop(context);
              
              // ✅ STEP 2: Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // ✅ STEP 3: Stop notification polling
                final notificationProvider = Provider.of<NotificationProvider>(
                  context, 
                  listen: false,
                );
                notificationProvider.stopPolling();
                
                // ✅ STEP 4: Logout
                final authProvider = Provider.of<AuthProvider>(
                  context, 
                  listen: false,
                );
                await authProvider.logout();
                
                // ✅ STEP 5: Close loading dialog
                if (context.mounted) {
                  Navigator.pop(context);
                }
                
                // ✅ STEP 6: Navigate to login - CLEAR ALL ROUTES
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false, // ✅ Remove ALL routes
                  );
                }
              } catch (e) {
                // ✅ STEP 7: Handle error
                if (context.mounted) {
                  Navigator.pop(context); // Close loading
                  AppUtils.showSnackBar(
                    context,
                    'Error saat logout: $e',
                    isError: true,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
