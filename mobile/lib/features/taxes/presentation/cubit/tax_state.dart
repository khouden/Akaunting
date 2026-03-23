import '../../../../data/models/tax_model.dart';

abstract class TaxState {
  const TaxState();
}

class TaxInitial extends TaxState {}

class TaxLoading extends TaxState {}

class TaxesLoaded extends TaxState {
  final List<TaxModel> taxes;
  const TaxesLoaded(this.taxes);
}

class TaxDetailLoaded extends TaxState {
  final TaxModel tax;
  const TaxDetailLoaded(this.tax);
}

class TaxError extends TaxState {
  final String message;
  const TaxError(this.message);
}

class TaxOperationSuccess extends TaxState {
  final String message;
  const TaxOperationSuccess(this.message);
}
