class UserModel {
  final int id;
  final String name;
  final String email;
  final String? locale;
  final bool enabled;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.locale,
    this.enabled = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      locale: json['locale'] as String?,
      enabled: json['enabled'] == true || json['enabled'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'locale': locale,
        'enabled': enabled,
      };

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';
}
