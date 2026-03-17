class TransactionModel {
  final int id;
  final String type;
  final String paidAt;
  final double amount;
  final String? amountFormatted;
  final String? description;
  final int? accountId;
  final int? categoryId;
  final int? contactId;
  final String? paymentMethod;
  final String? reference;
  final String? number;

  TransactionModel({
    required this.id,
    required this.type,
    required this.paidAt,
    required this.amount,
    this.amountFormatted,
    this.description,
    this.accountId,
    this.categoryId,
    this.contactId,
    this.paymentMethod,
    this.reference,
    this.number,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'expense',
      paidAt: json['paid_at'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      amountFormatted: json['amount_formatted'] as String?,
      description: json['description'] as String?,
      accountId: json['account_id'] as int?,
      categoryId: json['category_id'] as int?,
      contactId: json['contact_id'] as int?,
      paymentMethod: json['payment_method'] as String?,
      reference: json['reference'] as String?,
      number: json['number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'paid_at': paidAt,
      'amount': amount,
      'description': description,
      'account_id': accountId,
      'category_id': categoryId,
      'contact_id': contactId,
      'payment_method': paymentMethod,
      'reference': reference,
      'number': number,
    };
  }
}
