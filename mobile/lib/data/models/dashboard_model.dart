class DashboardModel {
  final int id;
  final int companyId;
  final String name;
  final bool enabled;
  final String? createdFrom;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  const DashboardModel({
    required this.id,
    required this.companyId,
    required this.name,
    this.enabled = true,
    this.createdFrom,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      companyId: json['company_id'] is int ? json['company_id'] : int.tryParse(json['company_id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? 'Unnamed',
      enabled: json['enabled'] == true || json['enabled'] == 1 || json['enabled'] == '1',
      createdFrom: json['created_from']?.toString(),
      createdBy: json['created_by'] is int ? json['created_by'] : int.tryParse(json['created_by']?.toString() ?? ''),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'enabled': enabled ? 1 : 0,
      };

  DashboardModel copyWith({
    int? id,
    int? companyId,
    String? name,
    bool? enabled,
    String? createdFrom,
    int? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return DashboardModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      createdFrom: createdFrom ?? this.createdFrom,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'DashboardModel(id: $id, name: $name, enabled: $enabled)';
}
