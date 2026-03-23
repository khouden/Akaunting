class ReportModel {
  final int id;
  final int companyId;
  final String className;
  final String name;
  final String description;
  final Map<String, dynamic> settings;
  final Map<String, dynamic>? data;
  final String createdFrom;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  ReportModel({
    required this.id,
    required this.companyId,
    required this.className,
    required this.name,
    required this.description,
    required this.settings,
    this.data,
    required this.createdFrom,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportModel.fromJson(dynamic source) {
    try {
      if (source == null || source is! Map) {
        throw Exception('Source is not a map');
      }

      final json = source is Map<String, dynamic> 
          ? source 
          : Map<String, dynamic>.from(source);

      Map<String, dynamic> parseMap(dynamic value) {
        if (value is Map<String, dynamic>) return value;
        if (value is Map) return Map<String, dynamic>.from(value);
        return <String, dynamic>{};
      }

      Map<String, dynamic>? parseNullableMap(dynamic value) {
        print('parseNullableMap received type: ${value.runtimeType}');
        if (value == null) return null;
        if (value is Map<String, dynamic>) return value;
        if (value is Map) return Map<String, dynamic>.from(value);
        print('parseNullableMap parsing failed, returning null for value: $value');
        return null;
      }

      return ReportModel(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        companyId: json['company_id'] is int ? json['company_id'] : int.tryParse(json['company_id']?.toString() ?? '0') ?? 0,
        className: json['class']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        settings: parseMap(json['settings']),
        data: parseNullableMap(json['data']),
        createdFrom: json['created_from']?.toString() ?? '',
        createdBy: json['created_by'] is int ? json['created_by'] : int.tryParse(json['created_by']?.toString() ?? '0') ?? 0,
        createdAt: json['created_at']?.toString() ?? '',
        updatedAt: json['updated_at']?.toString() ?? '',
      );
    } catch (e) {
      return ReportModel(
        id: 0,
        companyId: 0,
        className: '',
        name: 'Parsing Error',
        description: e.toString(),
        settings: {},
        data: null,
        createdFrom: '',
        createdBy: 0,
        createdAt: '',
        updatedAt: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'class': className,
      'name': name,
      'description': description,
      'settings': settings,
      'data': data,
      'created_from': createdFrom,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
