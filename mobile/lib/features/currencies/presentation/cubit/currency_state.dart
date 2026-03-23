import '../../../../data/models/currency_model.dart';

abstract class CurrencyState {
  const CurrencyState();
}

class CurrencyInitial extends CurrencyState {}

class CurrencyLoading extends CurrencyState {}

class CurrenciesLoaded extends CurrencyState {
  final List<CurrencyModel> currencies;
  const CurrenciesLoaded(this.currencies);
}

class CurrencyDetailLoaded extends CurrencyState {
  final CurrencyModel currency;
  const CurrencyDetailLoaded(this.currency);
}

class CurrencyError extends CurrencyState {
  final String message;
  const CurrencyError(this.message);
}

class CurrencyOperationSuccess extends CurrencyState {
  final String message;
  const CurrencyOperationSuccess(this.message);
}
