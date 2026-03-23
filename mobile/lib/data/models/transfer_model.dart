class TransferModel {
  final int id;
  final int companyId;
  final String fromAccount;
  final int fromAccountId;
  final String toAccount;
  final int toAccountId;
  final double amount;
  final String? amountFormatted;
  final String currencyCode;
  final String paidAt;
  final String? createdFrom;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  const TransferModel({
    required this.id,
    required this.companyId,
    required this.fromAccount,
    required this.fromAccountId,
    required this.toAccount,
    required this.toAccountId,
    required this.amount,
    this.amountFormatted,
    required this.currencyCode,
    required this.paidAt,
    this.createdFrom,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int? ?? 0,
      fromAccount: (json['from_account'] as String?) ?? 'N/A',
      fromAccountId: json['from_account_id'] as int? ?? 0,
      toAccount: (json['to_account'] as String?) ?? 'N/A',
      toAccountId: json['to_account_id'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      amountFormatted: json['amount_formatted'] as String?,
      currencyCode: (json['currency_code'] as String?) ?? 'USD',
      paidAt: (json['paid_at'] as String?) ?? '',
      createdFrom: json['created_from'] as String?,
      createdBy: json['created_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'from_account_id': fromAccountId,
        'to_account_id': toAccountId,
        'amount': amount,
        'transferred_at': paidAt,
      };
}
