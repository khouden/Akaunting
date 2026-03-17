import 'package:dio/dio.dart';
import '../../domain/repositories/reconciliation_repository.dart';
import '../../../../data/models/reconciliation_model.dart';
import '../../../../data/models/transaction_model.dart';

class ApiReconciliationRepository implements ReconciliationRepository {
  final Dio _dio;

  ApiReconciliationRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<ReconciliationModel>> getReconciliations({String? search, int page = 1}) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get('/api/reconciliations', queryParameters: queryParams);
      final data = response.data as Map<String, dynamic>;
      final List items = data['data'] as List;
      return items.map((json) => ReconciliationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ReconciliationModel> getReconciliation(int id) async {
    try {
      final response = await _dio.get('/api/reconciliations/$id');
      final data = response.data as Map<String, dynamic>;
      return ReconciliationModel.fromJson(data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ReconciliationModel> createReconciliation(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/reconciliations', data: data);
      final responseData = response.data as Map<String, dynamic>;
      return ReconciliationModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ReconciliationModel> updateReconciliation(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/api/reconciliations/$id', data: data);
      final responseData = response.data as Map<String, dynamic>;
      return ReconciliationModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteReconciliation(int id) async {
    try {
      await _dio.delete('/api/reconciliations/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions(int accountId, String startedAt, String endedAt) async {
    try {
      final queryParams = {
        'search': 'account_id:$accountId paid_at:>=$startedAt paid_at:<=$endedAt',
        'limit': 100 // Get enough for one page
      };
      final response = await _dio.get('/api/transactions', queryParameters: queryParams);
      final data = response.data as Map<String, dynamic>;
      final List items = data['data'] as List;
      return items.map((json) => TransactionModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) {
        return Exception(data['message']);
      }
      return Exception('Server error: ${e.response!.statusCode}');
    }
    return Exception('Network error. Please check your connection.');
  }
}
