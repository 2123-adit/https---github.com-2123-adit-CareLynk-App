import '../models/campaign_model.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class CampaignService {
  final ApiService _apiService = ApiService.instance;

  Future<ApiResponse<List<Campaign>>> getCampaigns({
    String? kategori,
    String? search,
  }) async {
    Map<String, String> queryParams = {};
    if (kategori != null) queryParams['kategori'] = kategori;
    if (search != null) queryParams['search'] = search;

    return await _apiService.get<List<Campaign>>(
      ApiConstants.campaigns,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => (data as List).map((item) => Campaign.fromJson(item)).toList(),
    );
  }

  Future<ApiResponse<Campaign>> getCampaignDetail(int id) async {
    return await _apiService.get<Campaign>(
      ApiConstants.campaignDetail(id),
      fromJson: (data) => Campaign.fromJson(data),
    );
  }

  Future<String> getCampaignReportUrl(int id) {
    return Future.value(ApiConstants.campaignDetail(id));
  }
}
