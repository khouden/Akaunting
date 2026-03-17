import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/transaction_repository.dart';
import 'transaction_state.dart';
import 'package:get_it/get_it.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _repository = GetIt.I<TransactionRepository>();

  TransactionCubit() : super(TransactionInitial());

  Future<void> fetchTransactions({Map<String, dynamic>? query}) async {
    emit(TransactionLoading());
    try {
      final transactions = await _repository.getTransactions(query: query);
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> fetchTransaction(int id) async {
    emit(TransactionLoading());
    try {
      final transaction = await _repository.getTransaction(id);
      emit(TransactionDetailLoaded(transaction));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> createTransaction(Map<String, dynamic> data) async {
    emit(TransactionLoading());
    try {
      await _repository.createTransaction(data);
      emit(const TransactionOperationSuccess('Transaction created successfully'));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> updateTransaction(int id, Map<String, dynamic> data) async {
    emit(TransactionLoading());
    try {
      await _repository.updateTransaction(id, data);
      emit(const TransactionOperationSuccess('Transaction updated successfully'));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> deleteTransaction(int id) async {
    emit(TransactionLoading());
    try {
      await _repository.deleteTransaction(id);
      emit(const TransactionOperationSuccess('Transaction deleted successfully'));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
