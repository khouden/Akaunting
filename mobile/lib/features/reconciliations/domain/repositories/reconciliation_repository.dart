import '../../../../data/models/reconciliation_model.dart';
import '../../../../data/models/transaction_model.dart';

abstract class ReconciliationRepository {
  Future<List<ReconciliationModel>> getReconciliations({String? search, int page = 1});
  Future<ReconciliationModel> getReconciliation(int id);
  Future<ReconciliationModel> createReconciliation(Map<String, dynamic> data);
  Future<ReconciliationModel> updateReconciliation(int id, Map<String, dynamic> data);
  Future<void> deleteReconciliation(int id);
  Future<List<TransactionModel>> getTransactions(int accountId, String startedAt, String endedAt);
}
