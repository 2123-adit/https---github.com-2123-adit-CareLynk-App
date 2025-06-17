class ApiConstants {
     static const String baseUrl = 'http://10.0.2.2:8000/api'; 
    //  static const String baseUrl = 'https://carelynk.my.id/api';
  //
    //  static const String baseUrl = 'http://192.168.63.250/api:5555'; // Physical device;
  
  // Auth endpoints
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String logout = '$baseUrl/logout';
  static const String user = '$baseUrl/user';
  
  // Campaign endpoints
  static const String campaigns = '$baseUrl/campaigns';
  static String campaignDetail(int id) => '$baseUrl/campaigns/$id';
  
  // Donation endpoints
  static const String donate = '$baseUrl/donasi';
  static const String donationHistory = '$baseUrl/donasi/history';
  
  // Topup endpoints
  static const String topup = '$baseUrl/topup';
  static const String topupHistory = '$baseUrl/topup/history';
  
  // Notification endpoints
  static const String notifications = '$baseUrl/notifikasi';
  static const String markAsRead = '$baseUrl/notifikasi/read';

  static const bool isDebugMode = true;
}

class AppStrings {
  static const String appName = 'Donation App';
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String name = 'Nama Lengkap';
  static const String confirmPassword = 'Konfirmasi Password';
  static const String forgotPassword = 'Lupa Password?';
  static const String dontHaveAccount = 'Belum punya akun?';
  static const String alreadyHaveAccount = 'Sudah punya akun?';
  static const String balance = 'Saldo';
  static const String campaigns = 'Kampanye';
  static const String donate = 'Donasi';
  static const String topup = 'Top Up';
  static const String history = 'Riwayat';
  static const String notifications = 'Notifikasi';
  static const String profile = 'Profil';
  static const String logout = 'Keluar';
}