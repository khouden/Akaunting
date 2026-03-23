import '../../../../core/network/api_client.dart';
import '../../data/models/report_model.dart';

class ReportRepository {
  final ApiClient apiClient;

  ReportRepository({required this.apiClient});

  Future<List<ReportModel>> getReports() async {
    final response = await apiClient.dio.get('/api/reports');
    final dynamic responseData = response.data['data'];
    if (responseData is List) {
      return responseData.map((json) => ReportModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<ReportModel> getReport(int id) async {
    final response = await apiClient.dio.get('/api/reports/$id');
    
    if (response.data is Map<String, dynamic>) {
      final Map<String, dynamic> data = response.data;
      // If it has 'id', it's already unwrapped!
      if (data.containsKey('id')) {
        return ReportModel.fromJson(data);
      }
      if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
        return ReportModel.fromJson(data['data']);
      }
      return ReportModel.fromJson(data);
    }
    
    return ReportModel.fromJson(response.data);
  }

  Future<ReportModel> createReport(Map<String, dynamic> data) async {
    final response = await apiClient.dio.post('/api/reports', data: data);
    
    if (response.data is Map<String, dynamic>) {
      final Map<String, dynamic> resData = response.data;
      if (resData.containsKey('id')) {
        return ReportModel.fromJson(resData);
      }
      if (resData.containsKey('data') && resData['data'] is Map<String, dynamic>) {
        return ReportModel.fromJson(resData['data']);
      }
      return ReportModel.fromJson(resData);
    }
    
    return ReportModel.fromJson(response.data);
  }

  Future<ReportModel> updateReport(int id, Map<String, dynamic> data) async {
    final response = await apiClient.dio.put('/api/reports/$id', data: data);
    
    if (response.data is Map<String, dynamic>) {
      final Map<String, dynamic> resData = response.data;
      if (resData.containsKey('id')) {
        return ReportModel.fromJson(resData);
      }
      if (resData.containsKey('data') && resData['data'] is Map<String, dynamic>) {
        return ReportModel.fromJson(resData['data']);
      }
      return ReportModel.fromJson(resData);
    }
    
    return ReportModel.fromJson(response.data);
  }

  Future<void> deleteReport(int id) async {
    await apiClient.dio.delete('/api/reports/$id');
  }
}
