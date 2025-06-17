import '../models/topup_model.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class TopupService {
  final ApiService _apiService = ApiService.instance;

  Future<ApiResponse<Topup>> requestTopup(double nominal) async {
    return await _apiService.post<Topup>(
      ApiConstants.topup,
      {'nominal': nominal},
      fromJson: (data) => Topup.fromJson(data),
    );
  }

  Future<ApiResponse<List<Topup>>> getTopupHistory() async {
    return await _apiService.get<List<Topup>>(
      ApiConstants.topupHistory,
      fromJson: (data) => (data as List).map((item) => Topup.fromJson(item)).toList(),
    );
  }
}
