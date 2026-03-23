import '../../../../data/models/transfer_model.dart';

abstract class TransferState {
  const TransferState();
}

class TransferInitial extends TransferState {}

class TransferLoading extends TransferState {}

class TransferLoaded extends TransferState {
  final List<TransferModel> transfers;

  const TransferLoaded(this.transfers);
}

class TransferDetailLoaded extends TransferState {
  final TransferModel transfer;

  const TransferDetailLoaded(this.transfer);
}

class TransferError extends TransferState {
  final String message;

  const TransferError(this.message);
}

class TransferOperationSuccess extends TransferState {
  final String message;

  const TransferOperationSuccess(this.message);
}
