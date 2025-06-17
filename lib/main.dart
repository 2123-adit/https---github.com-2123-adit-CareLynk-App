import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/campaign_provider.dart';
import 'providers/donation_provider.dart';
import 'providers/topup_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CampaignProvider()),
        ChangeNotifierProvider(create: (_) => DonationProvider()),
        ChangeNotifierProvider(create: (_) => TopupProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'CareLynk App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        
        // ✅ GLOBAL AUTH LISTENER
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Show splash screen while checking auth
            if (authProvider.isLoading) {
              return const SplashScreen();
            }
            
            // Navigate based on auth status
            if (authProvider.isAuthenticated && authProvider.user != null) {
              return const MainScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}