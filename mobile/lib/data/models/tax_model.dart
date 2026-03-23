class TaxModel {
  final int id;
  final int companyId;
  final String name;
  final double rate;
  final bool enabled;
  final String? createdFrom;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  const TaxModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.rate,
    this.enabled = true,
    this.createdFrom,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      enabled: json['enabled'] == true || json['enabled'] == 1,
      createdFrom: json['created_from'] as String?,
      createdBy: json['created_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'rate': rate,
        'enabled': enabled ? 1 : 0,
      };
}
