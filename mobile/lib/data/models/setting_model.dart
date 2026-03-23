class SettingModel {
  final int id;
  final int companyId;
  final String key;
  final String? value;

  const SettingModel({
    required this.id,
    required this.companyId,
    required this.key,
    this.value,
  });

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int? ?? 0,
      key: json['key'] as String? ?? '',
      value: json['value']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };
}
