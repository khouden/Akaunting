import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/reconciliation_model.dart';
import '../../data/models/transaction_model.dart';
import '../../features/reconciliations/domain/repositories/reconciliation_repository.dart';

// ─── States ───────────────────────────────────────────────────────────────────

abstract class ReconciliationState {}

class ReconciliationInitial extends ReconciliationState {}

class ReconciliationLoading extends ReconciliationState {}

class ReconciliationsLoaded extends ReconciliationState {
  final List<ReconciliationModel> reconciliations;
  ReconciliationsLoaded(this.reconciliations);
}

class ReconciliationTransactionsLoaded extends ReconciliationState {
  final List<TransactionModel> transactions;
  ReconciliationTransactionsLoaded(this.transactions);
}

class ReconciliationLoaded extends ReconciliationState {
  final ReconciliationModel reconciliation;
  ReconciliationLoaded(this.reconciliation);
}

class ReconciliationSaved extends ReconciliationState {
  final ReconciliationModel reconciliation;
  ReconciliationSaved(this.reconciliation);
}

class ReconciliationDeleted extends ReconciliationState {}

class ReconciliationError extends ReconciliationState {
  final String message;
  ReconciliationError(this.message);
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class ReconciliationCubit extends Cubit<ReconciliationState> {
  final ReconciliationRepository _reconciliationRepo;

  ReconciliationCubit({required ReconciliationRepository reconciliationRepository})
      : _reconciliationRepo = reconciliationRepository,
        super(ReconciliationInitial());

  Future<void> loadReconciliations({String? search}) async {
    emit(ReconciliationLoading());
    try {
      final reconciliations = await _reconciliationRepo.getReconciliations(search: search);
      emit(ReconciliationsLoaded(reconciliations));
    } catch (e) {
      emit(ReconciliationError(_parseError(e)));
    }
  }

  Future<void> loadReconciliation(int id) async {
    emit(ReconciliationLoading());
    try {
      final reconciliation = await _reconciliationRepo.getReconciliation(id);
      emit(ReconciliationLoaded(reconciliation));
    } catch (e) {
      emit(ReconciliationError(_parseError(e)));
    }
  }

  Future<void> loadTransactions(int accountId, String startedAt, String endedAt) async {
    // We shouldn't clear the whole forms state maybe, but keeping it simple:
    try {
      final transactions = await _reconciliationRepo.getTransactions(accountId, startedAt, endedAt);
      emit(ReconciliationTransactionsLoaded(transactions));
    } catch (e) {
      // Ignored for now or emit un-disruptive error
    }
  }

  Future<void> createReconciliation(Map<String, dynamic> data) async {
    emit(ReconciliationLoading());
    try {
      final reconciliation = await _reconciliationRepo.createReconciliation(data);
      emit(ReconciliationSaved(reconciliation));
    } catch (e) {
      emit(ReconciliationError(_parseError(e)));
    }
  }

  Future<void> updateReconciliation(int id, Map<String, dynamic> data) async {
    emit(ReconciliationLoading());
    try {
      final reconciliation = await _reconciliationRepo.updateReconciliation(id, data);
      emit(ReconciliationSaved(reconciliation));
    } catch (e) {
      emit(ReconciliationError(_parseError(e)));
    }
  }

  Future<void> deleteReconciliation(int id) async {
    emit(ReconciliationLoading());
    try {
      await _reconciliationRepo.deleteReconciliation(id);
      emit(ReconciliationDeleted());
    } catch (e) {
      emit(ReconciliationError(_parseError(e)));
    }
  }

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) return msg.substring(11);
    return 'An unexpected error occurred. Please try again.';
  }
}
