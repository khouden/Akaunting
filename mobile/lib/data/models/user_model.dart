/// User model with roles and permissions for authorization.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? locale;
  final bool enabled;
  final List<String> roles;
  final List<String> permissions;
  final List<UserCompany> companies;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.locale,
    this.enabled = true,
    this.roles = const [],
    this.permissions = const [],
    this.companies = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse roles
    final rolesJson = json['roles'] as List<dynamic>? ?? [];
    final roles = rolesJson.map((r) {
      if (r is Map<String, dynamic>) {
        return r['name']?.toString() ?? '';
      }
      return r.toString();
    }).where((r) => r.isNotEmpty).toList();

    // Parse permissions (may come from roles or directly)
    final permissionsJson = json['permissions'] as List<dynamic>? ?? [];
    final permissions = permissionsJson.map((p) {
      if (p is Map<String, dynamic>) {
        return p['name']?.toString() ?? '';
      }
      return p.toString();
    }).where((p) => p.isNotEmpty).toList();

    // Parse companies
    final companiesJson = json['companies'] as List<dynamic>? ?? [];
    final companies = companiesJson
        .map((c) => UserCompany.fromJson(c as Map<String, dynamic>))
        .toList();

    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      locale: json['locale'] as String?,
      enabled: json['enabled'] == true || json['enabled'] == 1,
      roles: roles,
      permissions: permissions,
      companies: companies,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'locale': locale,
        'enabled': enabled,
        'roles': roles,
        'permissions': permissions,
        'companies': companies.map((c) => c.toJson()).toList(),
      };

  // ─── Role checks ────────────────────────────────────────────────────────────

  bool get isAdmin => roles.contains('admin');
  bool get isManager => roles.contains('manager');
  bool get isAccountant => roles.contains('accountant');
  bool get isCustomer => roles.contains('customer');

  /// Returns true if user has any of the admin-level roles.
  bool get hasAdminAccess => isAdmin || isManager;

  // ─── Permission checks ──────────────────────────────────────────────────────

  /// Check if user has a specific permission.
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  /// Check if user can perform CRUD action on a resource.
  /// [action] is one of: create, read, update, delete
  /// [resource] is the resource name (e.g., 'auth-users', 'banking-accounts')
  bool can(String action, String resource) {
    return hasPermission('$action-$resource');
  }

  /// Check if user can read a resource.
  bool canRead(String resource) => can('read', resource);

  /// Check if user can create a resource.
  bool canCreate(String resource) => can('create', resource);

  /// Check if user can update a resource.
  bool canUpdate(String resource) => can('update', resource);

  /// Check if user can delete a resource.
  bool canDelete(String resource) => can('delete', resource);

  /// Check if user has API access.
  bool get hasApiAccess => hasPermission('read-api');

  /// Check if user has admin panel access.
  bool get hasAdminPanelAccess => hasPermission('read-admin-panel');

  /// Check if user has client portal access only.
  bool get hasClientPortalAccess => hasPermission('read-client-portal');

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? locale,
    bool? enabled,
    List<String>? roles,
    List<String>? permissions,
    List<UserCompany>? companies,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      locale: locale ?? this.locale,
      enabled: enabled ?? this.enabled,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      companies: companies ?? this.companies,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, email: $email, roles: $roles)';
}

/// Company associated with a user.
class UserCompany {
  final int id;
  final String name;
  final String? email;
  final String? currency;
  final bool enabled;

  const UserCompany({
    required this.id,
    required this.name,
    this.email,
    this.currency,
    this.enabled = true,
  });

  factory UserCompany.fromJson(Map<String, dynamic> json) {
    return UserCompany(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown Company',
      email: json['email'] as String?,
      currency: json['currency'] as String?,
      enabled: json['enabled'] == true || json['enabled'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'currency': currency,
        'enabled': enabled,
      };
}
