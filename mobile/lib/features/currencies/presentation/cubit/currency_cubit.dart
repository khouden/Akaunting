import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/repositories/currency_repository.dart';
import 'currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  final CurrencyRepository _repository = GetIt.I<CurrencyRepository>();

  CurrencyCubit() : super(CurrencyInitial());

  Future<void> fetchCurrencies({Map<String, dynamic>? query}) async {
    emit(CurrencyLoading());
    try {
      final currencies = await _repository.getCurrencies(query: query);
      emit(CurrenciesLoaded(currencies));
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }

  Future<void> fetchCurrency(int id) async {
    emit(CurrencyLoading());
    try {
      final currency = await _repository.getCurrency(id);
      emit(CurrencyDetailLoaded(currency));
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }

  Future<void> createCurrency(Map<String, dynamic> data) async {
    emit(CurrencyLoading());
    try {
      await _repository.createCurrency(data);
      emit(const CurrencyOperationSuccess('Currency created successfully'));
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }

  Future<void> updateCurrency(int id, Map<String, dynamic> data) async {
    emit(CurrencyLoading());
    try {
      await _repository.updateCurrency(id, data);
      emit(const CurrencyOperationSuccess('Currency updated successfully'));
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }

  Future<void> deleteCurrency(int id) async {
    emit(CurrencyLoading());
    try {
      await _repository.deleteCurrency(id);
      emit(const CurrencyOperationSuccess('Currency deleted successfully'));
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }

  Future<void> enableCurrency(int id) async {
    try {
      await _repository.enableCurrency(id);
      emit(const CurrencyOperationSuccess('Currency enabled'));
      fetchCurrencies();
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }

  Future<void> disableCurrency(int id) async {
    try {
      await _repository.disableCurrency(id);
      emit(const CurrencyOperationSuccess('Currency disabled'));
      fetchCurrencies();
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }
}
