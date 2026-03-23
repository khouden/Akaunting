import '../../../../data/models/dashboard_model.dart';

abstract class DashboardRepository {
  Future<List<DashboardModel>> getDashboards({String? search, int page = 1});
  Future<DashboardModel> getDashboard(int id);
  Future<DashboardModel> createDashboard(Map<String, dynamic> data);
  Future<DashboardModel> updateDashboard(int id, Map<String, dynamic> data);
  Future<void> deleteDashboard(int id);
  Future<DashboardModel> enableDashboard(int id);
  Future<DashboardModel> disableDashboard(int id);
}
