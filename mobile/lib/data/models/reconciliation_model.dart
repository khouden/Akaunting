import 'account_model.dart'; // To nest the account information

class ReconciliationModel {
  final int id;
  final int companyId;
  final int accountId;
  final String startedAt;
  final String endedAt;
  final double closingBalance;
  final String? closingBalanceFormatted;
  final bool reconciled;
  final String? createdFrom;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final AccountModel? account;

  const ReconciliationModel({
    required this.id,
    required this.companyId,
    required this.accountId,
    required this.startedAt,
    required this.endedAt,
    required this.closingBalance,
    this.closingBalanceFormatted,
    this.reconciled = false,
    this.createdFrom,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.account,
  });

  factory ReconciliationModel.fromJson(Map<String, dynamic> json) {
    return ReconciliationModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      accountId: json['account_id'] as int,
      startedAt: json['started_at'] as String,
      endedAt: json['ended_at'] as String,
      closingBalance: (json['closing_balance'] as num?)?.toDouble() ?? 0.0,
      closingBalanceFormatted: json['closing_balance_formatted'] as String?,
      reconciled: json['reconciled'] == true || json['reconciled'] == 1 || json['reconciled'] == '1',
      createdFrom: json['created_from'] as String?,
      createdBy: json['created_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      account: json['account'] != null ? AccountModel.fromJson(json['account']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'account_id': accountId,
        'started_at': startedAt,
        'ended_at': endedAt,
        'closing_balance': closingBalance,
        'reconciled': reconciled ? 1 : 0,
      };

  ReconciliationModel copyWith({
    int? id,
    int? companyId,
    int? accountId,
    String? startedAt,
    String? endedAt,
    double? closingBalance,
    String? closingBalanceFormatted,
    bool? reconciled,
    String? createdFrom,
    int? createdBy,
    String? createdAt,
    String? updatedAt,
    AccountModel? account,
  }) {
    return ReconciliationModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      accountId: accountId ?? this.accountId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      closingBalance: closingBalance ?? this.closingBalance,
      closingBalanceFormatted: closingBalanceFormatted ?? this.closingBalanceFormatted,
      reconciled: reconciled ?? this.reconciled,
      createdFrom: createdFrom ?? this.createdFrom,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      account: account ?? this.account,
    );
  }

  @override
  String toString() => 'ReconciliationModel(id: $id, accountId: $accountId, balance: $closingBalance)';
}
