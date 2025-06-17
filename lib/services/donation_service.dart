import '../models/donation_model.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class DonationService {
  final ApiService _apiService = ApiService.instance;

  // ✅ UPDATE: Method donate dengan parameter baru
  Future<ApiResponse<dynamic>> donate({
    required int campaignId,
    required double nominal,
    bool isAnonymous = false,        // ✅ TAMBAH
    String? donorName,               // ✅ TAMBAH
    String? message,                 // ✅ TAMBAH
  }) async {
    return await _apiService.post<dynamic>(
      ApiConstants.donate,
      {
        'campaign_id': campaignId,
        'nominal': nominal,
        'is_anonymous': isAnonymous,   // ✅ TAMBAH
        'donor_name': donorName,       // ✅ TAMBAH
        'message': message,            // ✅ TAMBAH
      },
    );
  }

  Future<ApiResponse<List<Donation>>> getDonationHistory() async {
    return await _apiService.get<List<Donation>>(
      ApiConstants.donationHistory,
      fromJson: (data) => (data as List).map((item) => Donation.fromJson(item)).toList(),
    );
  }
}