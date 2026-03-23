import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/repositories/tax_repository.dart';
import 'tax_state.dart';

class TaxCubit extends Cubit<TaxState> {
  final TaxRepository _repository = GetIt.I<TaxRepository>();

  TaxCubit() : super(TaxInitial());

  Future<void> fetchTaxes({Map<String, dynamic>? query}) async {
    emit(TaxLoading());
    try {
      final taxes = await _repository.getTaxes(query: query);
      emit(TaxesLoaded(taxes));
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }

  Future<void> fetchTax(int id) async {
    emit(TaxLoading());
    try {
      final tax = await _repository.getTax(id);
      emit(TaxDetailLoaded(tax));
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }

  Future<void> createTax(Map<String, dynamic> data) async {
    emit(TaxLoading());
    try {
      await _repository.createTax(data);
      emit(const TaxOperationSuccess('Tax created successfully'));
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }

  Future<void> updateTax(int id, Map<String, dynamic> data) async {
    emit(TaxLoading());
    try {
      await _repository.updateTax(id, data);
      emit(const TaxOperationSuccess('Tax updated successfully'));
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }

  Future<void> deleteTax(int id) async {
    emit(TaxLoading());
    try {
      await _repository.deleteTax(id);
      emit(const TaxOperationSuccess('Tax deleted successfully'));
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }

  Future<void> enableTax(int id) async {
    try {
      await _repository.enableTax(id);
      emit(const TaxOperationSuccess('Tax enabled'));
      fetchTaxes();
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }

  Future<void> disableTax(int id) async {
    try {
      await _repository.disableTax(id);
      emit(const TaxOperationSuccess('Tax disabled'));
      fetchTaxes();
    } catch (e) {
      emit(TaxError(e.toString()));
    }
  }
}
