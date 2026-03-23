import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/dashboard_model.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardsLoaded extends DashboardState {
  final List<DashboardModel> dashboards;
  DashboardsLoaded(this.dashboards);
}

class DashboardLoaded extends DashboardState {
  final DashboardModel dashboard;
  DashboardLoaded(this.dashboard);
}

class DashboardSaved extends DashboardState {
  final DashboardModel dashboard;
  DashboardSaved(this.dashboard);
}

class DashboardDeleted extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepo;

  DashboardCubit({required DashboardRepository dashboardRepository})
      : _dashboardRepo = dashboardRepository,
        super(DashboardInitial());

  Future<void> loadDashboards({String? search}) async {
    emit(DashboardLoading());
    try {
      final dashboards = await _dashboardRepo.getDashboards(search: search);
      emit(DashboardsLoaded(dashboards));
    } catch (e) {
      emit(DashboardError(_parseError(e)));
    }
  }

  Future<void> loadDashboard(int id) async {
    emit(DashboardLoading());
    try {
      final dashboard = await _dashboardRepo.getDashboard(id);
      emit(DashboardLoaded(dashboard));
    } catch (e) {
      emit(DashboardError(_parseError(e)));
    }
  }

  Future<void> createDashboard(Map<String, dynamic> data) async {
    emit(DashboardLoading());
    try {
      final dashboard = await _dashboardRepo.createDashboard(data);
      emit(DashboardSaved(dashboard));
    } catch (e) {
      emit(DashboardError(_parseError(e)));
    }
  }

  Future<void> updateDashboard(int id, Map<String, dynamic> data) async {
    emit(DashboardLoading());
    try {
      final dashboard = await _dashboardRepo.updateDashboard(id, data);
      emit(DashboardSaved(dashboard));
    } catch (e) {
      emit(DashboardError(_parseError(e)));
    }
  }

  Future<void> deleteDashboard(int id) async {
    emit(DashboardLoading());
    try {
      await _dashboardRepo.deleteDashboard(id);
      emit(DashboardDeleted());
    } catch (e) {
      emit(DashboardError(_parseError(e)));
    }
  }

  Future<void> enableDashboard(int id) async {
    try {
      final dashboard = await _dashboardRepo.enableDashboard(id);
      emit(DashboardSaved(dashboard));
    } catch (e) {
      emit(DashboardError(_parseError(e)));
    }
  }

  Future<void> disableDashboard(int id) async {
    try {
      final dashboard = await _dashboardRepo.disableDashboard(id);
      emit(DashboardSaved(dashboard));
    } catch (e) {
      emit(DashboardError(_parseError(e)));
    }
  }

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) return msg.substring(11);
    return 'An unexpected error occurred. Please try again.';
  }
}
