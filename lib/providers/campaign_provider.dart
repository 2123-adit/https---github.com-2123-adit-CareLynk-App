import 'package:flutter/material.dart';
import '../models/campaign_model.dart';
import '../services/campaign_service.dart';

class CampaignProvider extends ChangeNotifier {
  final CampaignService _campaignService = CampaignService();
  
  List<Campaign> _campaigns = [];
  List<Campaign> _filteredCampaigns = [];
  Campaign? _selectedCampaign;
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  List<Campaign> get campaigns => _filteredCampaigns;
  Campaign? get selectedCampaign => _selectedCampaign;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<String> get categories => [
    'Semua',
    'Pendidikan',
    'Kesehatan',
    'Bencana',
    'Sosial',
  ];

  Future<void> loadCampaigns() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _campaignService.getCampaigns();
      
      if (response.success && response.data != null) {
        _campaigns = response.data!;
        _applyFilters();
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to load campaigns: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCampaignDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _campaignService.getCampaignDetail(id);
      
      if (response.success && response.data != null) {
        _selectedCampaign = response.data;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to load campaign detail: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredCampaigns = _campaigns.where((campaign) {
      // Category filter
      bool categoryMatch = _selectedCategory == 'Semua' || 
                          campaign.kategori == _selectedCategory;
      
      // Search filter
      bool searchMatch = _searchQuery.isEmpty ||
                        campaign.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        campaign.deskripsi.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return categoryMatch && searchMatch;
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
