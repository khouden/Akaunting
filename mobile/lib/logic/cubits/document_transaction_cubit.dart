import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../../features/documents/domain/repositories/document_repository.dart';

abstract class DocumentTransactionState {}

class DocumentTransactionInitial extends DocumentTransactionState {}

class DocumentTransactionLoading extends DocumentTransactionState {}

class DocumentTransactionsLoaded extends DocumentTransactionState {
  final List<TransactionModel> transactions;
  DocumentTransactionsLoaded(this.transactions);
}

class DocumentTransactionLoaded extends DocumentTransactionState {
  final TransactionModel transaction;
  DocumentTransactionLoaded(this.transaction);
}

class DocumentTransactionSaved extends DocumentTransactionState {
  final TransactionModel transaction;
  DocumentTransactionSaved(this.transaction);
}

class DocumentTransactionDeleted extends DocumentTransactionState {}

class DocumentTransactionError extends DocumentTransactionState {
  final String message;
  DocumentTransactionError(this.message);
}

class DocumentTransactionCubit extends Cubit<DocumentTransactionState> {
  final DocumentRepository _documentRepo;

  DocumentTransactionCubit({required DocumentRepository documentRepository})
      : _documentRepo = documentRepository,
        super(DocumentTransactionInitial());

  Future<void> loadDocumentTransactions(int documentId) async {
    emit(DocumentTransactionLoading());
    try {
      final transactions = await _documentRepo.getDocumentTransactions(documentId);
      emit(DocumentTransactionsLoaded(transactions));
    } catch (e) {
      emit(DocumentTransactionError(_parseError(e)));
    }
  }

  Future<void> loadDocumentTransaction(int documentId, int transactionId) async {
    emit(DocumentTransactionLoading());
    try {
      final transaction = await _documentRepo.getDocumentTransaction(documentId, transactionId);
      emit(DocumentTransactionLoaded(transaction));
    } catch (e) {
      emit(DocumentTransactionError(_parseError(e)));
    }
  }

  Future<void> createDocumentTransaction(int documentId, Map<String, dynamic> data) async {
    emit(DocumentTransactionLoading());
    try {
      final transaction = await _documentRepo.createDocumentTransaction(documentId, data);
      emit(DocumentTransactionSaved(transaction));
    } catch (e) {
      emit(DocumentTransactionError(_parseError(e)));
    }
  }

  Future<void> updateDocumentTransaction(int documentId, int transactionId, Map<String, dynamic> data) async {
    emit(DocumentTransactionLoading());
    try {
      final transaction = await _documentRepo.updateDocumentTransaction(documentId, transactionId, data);
      emit(DocumentTransactionSaved(transaction));
    } catch (e) {
      emit(DocumentTransactionError(_parseError(e)));
    }
  }

  Future<void> deleteDocumentTransaction(int documentId, int transactionId) async {
    emit(DocumentTransactionLoading());
    try {
      await _documentRepo.deleteDocumentTransaction(documentId, transactionId);
      emit(DocumentTransactionDeleted());
    } catch (e) {
      emit(DocumentTransactionError(_parseError(e)));
    }
  }

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) return msg.substring(11);
    return 'An unexpected error occurred. Please try again.';
  }
}
