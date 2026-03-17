import '../../../../data/models/transaction_model.dart';
import 'package:flutter/foundation.dart';

abstract class TransactionState {
  const TransactionState();
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;

  const TransactionLoaded(this.transactions);
}

class TransactionDetailLoaded extends TransactionState {
  final TransactionModel transaction;
  
  const TransactionDetailLoaded(this.transaction);
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);
}

class TransactionOperationSuccess extends TransactionState {
  final String message;

  const TransactionOperationSuccess(this.message);
}
