class CurrencyModel {
  final int id;
  final int companyId;
  final String name;
  final String code;
  final double rate;
  final bool enabled;
  final int? precision;
  final String? symbol;
  final int? symbolFirst;
  final String? decimalMark;
  final String? thousandsSeparator;
  final String? createdFrom;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  const CurrencyModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.code,
    required this.rate,
    this.enabled = true,
    this.precision,
    this.symbol,
    this.symbolFirst,
    this.decimalMark,
    this.thousandsSeparator,
    this.createdFrom,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
      enabled: json['enabled'] == true || json['enabled'] == 1,
      precision: json['precision'] as int?,
      symbol: json['symbol'] as String?,
      symbolFirst: json['symbol_first'] as int?,
      decimalMark: json['decimal_mark'] as String?,
      thousandsSeparator: json['thousands_separator'] as String?,
      createdFrom: json['created_from'] as String?,
      createdBy: json['created_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'rate': rate,
        'enabled': enabled ? 1 : 0,
        'precision': precision,
        'symbol': symbol,
        'symbol_first': symbolFirst,
        'decimal_mark': decimalMark,
        'thousands_separator': thousandsSeparator,
      };
}
