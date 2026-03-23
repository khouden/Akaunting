import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/report_repository.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository repository;

  ReportCubit({required this.repository}) : super(ReportInitial());

  Future<void> fetchReports() async {
    try {
      emit(ReportLoading());
      final reports = await repository.getReports();
      emit(ReportsLoaded(reports));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> fetchReport(int id) async {
    try {
      emit(ReportLoading());
      final report = await repository.getReport(id);
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> createReport(Map<String, dynamic> data) async {
    try {
      emit(ReportLoading());
      await repository.createReport(data);
      emit(const ReportOperationSuccess('Report created successfully'));
      fetchReports();
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> updateReport(int id, Map<String, dynamic> data) async {
    try {
      emit(ReportLoading());
      await repository.updateReport(id, data);
      emit(const ReportOperationSuccess('Report updated successfully'));
      fetchReports();
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> deleteReport(int id) async {
    try {
      emit(ReportLoading());
      await repository.deleteReport(id);
      emit(const ReportOperationSuccess('Report deleted successfully'));
      fetchReports();
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
