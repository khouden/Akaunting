class CategoryModel {
  final int id;
  final int companyId;
  final String name;
  final String type;
  final String color;
  final bool enabled;
  final int? parentId;
  final String? createdFrom;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  const CategoryModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    required this.color,
    this.enabled = true,
    this.parentId,
    this.createdFrom,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      color: json['color'] as String? ?? '#6DA252',
      enabled: json['enabled'] == true || json['enabled'] == 1,
      parentId: json['parent_id'] as int?,
      createdFrom: json['created_from'] as String?,
      createdBy: json['created_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'color': color,
        'enabled': enabled ? 1 : 0,
        'parent_id': parentId,
      };
}
