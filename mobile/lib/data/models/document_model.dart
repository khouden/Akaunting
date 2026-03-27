class DocumentModel {
  final int id;
  final int companyId;
  final String type;
  final String documentNumber;
  final String status;
  final double amount;
  final int contactId;
  final String? contactName;
  final String? issueDate;
  final String? dueDate;
  final String? createdAt;
  final String? currencyCode;

  const DocumentModel({
    required this.id,
    required this.companyId,
    required this.type,
    required this.documentNumber,
    required this.status,
    this.amount = 0.0,
    required this.contactId,
    this.contactName,
    this.issueDate,
    this.dueDate,
    this.createdAt,
    this.currencyCode,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      type: json['type'] as String,
      documentNumber: json['document_number'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      contactId: json['contact_id'] as int,
      contactName: json['contact_name'] as String?,
      issueDate: json['issued_at'] as String?,
      dueDate: json['due_at'] as String?,
      createdAt: json['created_at'] as String?,
      currencyCode: json['currency_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'document_number': documentNumber,
        'status': status,
        'amount': amount,
        'contact_id': contactId,
        'issued_at': issueDate,
        'due_at': dueDate,
        'currency_code': 'USD',
        'currency_rate': 1,
        'category_id': 1,
        'items': [
          {
            'name': 'Custom Service',
            'price': amount,
            'quantity': 1,
            'currency': 'USD',
          }
        ]
      };

  DocumentModel copyWith({
    int? id,
    int? companyId,
    String? type,
    String? documentNumber,
    String? status,
    double? amount,
    int? contactId,
    String? contactName,
    String? issueDate,
    String? dueDate,
    String? createdAt,
    String? currencyCode,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      type: type ?? this.type,
      documentNumber: documentNumber ?? this.documentNumber,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      contactId: contactId ?? this.contactId,
      contactName: contactName ?? this.contactName,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  String toString() => 'DocumentModel(id: $id, type: $type, documentNumber: $documentNumber, status: $status)';
}
