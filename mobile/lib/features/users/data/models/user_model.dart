class UserModel {
  final int id;
  final String name;
  final String email;
  final String? locale;
  final String? landingPage;
  final bool enabled;
  final String? createdFrom;
  final int? createdBy;
  final String? lastLoggedInAt;
  final String? createdAt;
  final String? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.locale,
    this.landingPage,
    this.enabled = true,
    this.createdFrom,
    this.createdBy,
    this.lastLoggedInAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? 'Unknown',
      email: (json['email'] as String?) ?? '',
      locale: json['locale'] as String?,
      landingPage: json['landing_page'] as String?,
      enabled: json['enabled'] == true || json['enabled'] == 1,
      createdFrom: json['created_from'] as String?,
      createdBy: json['created_by'] as int?,
      lastLoggedInAt: json['last_logged_in_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'locale': locale,
    'landing_page': landingPage,
    'enabled': enabled,
    'created_from': createdFrom,
    'created_by': createdBy,
    'last_logged_in_at': lastLoggedInAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? locale,
    String? landingPage,
    bool? enabled,
    String? createdFrom,
    int? createdBy,
    String? lastLoggedInAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      locale: locale ?? this.locale,
      landingPage: landingPage ?? this.landingPage,
      enabled: enabled ?? this.enabled,
      createdFrom: createdFrom ?? this.createdFrom,
      createdBy: createdBy ?? this.createdBy,
      lastLoggedInAt: lastLoggedInAt ?? this.lastLoggedInAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
