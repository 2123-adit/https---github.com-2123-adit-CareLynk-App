import 'package:flutter/material.dart';
import '../models/donation_model.dart';
import '../services/donation_service.dart';

class DonationProvider extends ChangeNotifier {
  final DonationService _donationService = DonationService();

  List<Donation> _donations = [];
  bool _isLoading = false;
  bool _isDonating = false;
  String? _error;

  List<Donation> get donations => _donations;
  bool get isLoading => _isLoading;
  bool get isDonating => _isDonating;
  String? get error => _error;

  // Helper untuk mendeteksi session expired
  bool _isSessionExpired(String message) {
    return message.toLowerCase().contains('session expired') ||
           message.toLowerCase().contains('unauthorized');
  }

  Future<bool> makeDonation({
    required int campaignId,
    required double nominal,
    bool isAnonymous = false,
    String? donorName,
    String? message,
  }) async {
    _isDonating = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _donationService.donate(
        campaignId: campaignId,
        nominal: nominal,
        isAnonymous: isAnonymous,
        donorName: donorName,
        message: message,
      );

      _isDonating = false;
      notifyListeners();

      if (response.success) {
        await loadDonationHistory();
        return true;
      } else {
        _error = response.message;

        // ✅ Handle session expired (401 Unauthorized)
        if (_isSessionExpired(response.message)) {
          // Bisa tambahkan pemicu logout atau navigasi ke login jika perlu
          // Contoh: _authProvider.logout(); atau panggil callback
          return false;
        }

        return false;
      }
    } catch (e) {
      _error = 'Failed to make donation: ${e.toString()}';
      _isDonating = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadDonationHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _donationService.getDonationHistory();

      if (response.success && response.data != null) {
        _donations = response.data!;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to load donation history: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
