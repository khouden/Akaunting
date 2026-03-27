import '../../../../data/models/document_model.dart';
import '../../../../data/models/transaction_model.dart';

abstract class DocumentRepository {
  Future<List<DocumentModel>> getDocuments({String? search, int page = 1});
  Future<DocumentModel> getDocument(int id);
  Future<DocumentModel> createDocument(Map<String, dynamic> data);
  Future<DocumentModel> updateDocument(int id, Map<String, dynamic> data);
  Future<void> deleteDocument(int id);
  Future<DocumentModel> markAsReceived(int id);

  // Document Transactions
  Future<List<TransactionModel>> getDocumentTransactions(int documentId);
  Future<TransactionModel> getDocumentTransaction(int documentId, int transactionId);
  Future<TransactionModel> createDocumentTransaction(int documentId, Map<String, dynamic> data);
  Future<TransactionModel> updateDocumentTransaction(int documentId, int transactionId, Map<String, dynamic> data);
  Future<void> deleteDocumentTransaction(int documentId, int transactionId);
}
