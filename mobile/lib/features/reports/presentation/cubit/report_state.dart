import 'package:equatable/equatable.dart';
import '../../data/models/report_model.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportsLoaded extends ReportState {
  final List<ReportModel> reports;

  const ReportsLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class ReportLoaded extends ReportState {
  final ReportModel report;

  const ReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

class ReportOperationSuccess extends ReportState {
  final String message;

  const ReportOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}
