import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../domain/repositories/transfer_repository.dart';
import 'transfer_state.dart';

class TransferCubit extends Cubit<TransferState> {
  final TransferRepository _repository = GetIt.I<TransferRepository>();

  TransferCubit() : super(TransferInitial());

  Future<void> fetchTransfers({Map<String, dynamic>? query}) async {
    emit(TransferLoading());
    try {
      final transfers = await _repository.getTransfers(query: query);
      emit(TransferLoaded(transfers));
    } catch (e) {
      emit(TransferError(e.toString()));
    }
  }

  Future<void> fetchTransfer(int id) async {
    emit(TransferLoading());
    try {
      final transfer = await _repository.getTransfer(id);
      emit(TransferDetailLoaded(transfer));
    } catch (e) {
      emit(TransferError(e.toString()));
    }
  }

  Future<void> createTransfer(Map<String, dynamic> data) async {
    emit(TransferLoading());
    try {
      await _repository.createTransfer(data);
      emit(const TransferOperationSuccess('Transfer created successfully'));
    } catch (e) {
      emit(TransferError(e.toString()));
    }
  }

  Future<void> updateTransfer(int id, Map<String, dynamic> data) async {
    emit(TransferLoading());
    try {
      await _repository.updateTransfer(id, data);
      emit(const TransferOperationSuccess('Transfer updated successfully'));
    } catch (e) {
      emit(TransferError(e.toString()));
    }
  }

  Future<void> deleteTransfer(int id) async {
    emit(TransferLoading());
    try {
      await _repository.deleteTransfer(id);
      emit(const TransferOperationSuccess('Transfer deleted successfully'));
    } catch (e) {
      emit(TransferError(e.toString()));
    }
  }
}
