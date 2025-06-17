import 'package:flutter/material.dart';
import '../models/topup_model.dart';
import '../services/topup_service.dart';

class TopupProvider extends ChangeNotifier {
  final TopupService _topupService = TopupService();
  
  List<Topup> _topups = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  List<Topup> get topups => _topups;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  Future<bool> requestTopup(double nominal) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _topupService.requestTopup(nominal);
      
      _isProcessing = false;
      notifyListeners();
      
      if (response.success) {
        // Refresh topup history
        await loadTopupHistory();
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = 'Failed to request topup: ${e.toString()}';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadTopupHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _topupService.getTopupHistory();
      
      if (response.success && response.data != null) {
        _topups = response.data!;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to load topup history: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
