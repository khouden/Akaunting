import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

/// Service that provides centralized permission checking for the application.
///
/// This service maps backend permissions to UI features and provides
/// role-based access control throughout the app.
class PermissionService {
  final UserModel? _user;

  PermissionService({UserModel? user}) : _user = user;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;

  // ─── Role Checks ────────────────────────────────────────────────────────────

  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isManager => _user?.isManager ?? false;
  bool get isAccountant => _user?.isAccountant ?? false;
  bool get isCustomer => _user?.isCustomer ?? false;
  bool get hasAdminAccess => _user?.hasAdminAccess ?? false;

  // ─── Permission Checks ──────────────────────────────────────────────────────

  bool hasPermission(String permission) {
    return _user?.hasPermission(permission) ?? false;
  }

  bool can(String action, String resource) {
    return _user?.can(action, resource) ?? false;
  }

  // ─── Feature Access Checks ──────────────────────────────────────────────────

  /// Check if user can access the admin panel features.
  bool get canAccessAdminPanel {
    return _user?.hasAdminPanelAccess ?? false;
  }

  /// Check if user can only access client portal.
  bool get isClientPortalOnly {
    return (_user?.hasClientPortalAccess ?? false) && !canAccessAdminPanel;
  }

  /// Check if user has API access (required for mobile app).
  bool get hasApiAccess {
    return _user?.hasApiAccess ?? false;
  }

  // ─── Module Access ──────────────────────────────────────────────────────────

  /// Users management
  bool get canViewUsers => can('read', 'auth-users');
  bool get canCreateUsers => can('create', 'auth-users');
  bool get canUpdateUsers => can('update', 'auth-users');
  bool get canDeleteUsers => can('delete', 'auth-users');

  /// Companies management
  bool get canViewCompanies => can('read', 'common-companies');
  bool get canCreateCompanies => can('create', 'common-companies');
  bool get canUpdateCompanies => can('update', 'common-companies');
  bool get canDeleteCompanies => can('delete', 'common-companies');

  /// Dashboards
  bool get canViewDashboards => can('read', 'common-dashboards');
  bool get canCreateDashboards => can('create', 'common-dashboards');
  bool get canUpdateDashboards => can('update', 'common-dashboards');
  bool get canDeleteDashboards => can('delete', 'common-dashboards');

  /// Items
  bool get canViewItems => can('read', 'common-items');
  bool get canCreateItems => can('create', 'common-items');
  bool get canUpdateItems => can('update', 'common-items');
  bool get canDeleteItems => can('delete', 'common-items');

  /// Contacts (Customers/Vendors)
  bool get canViewCustomers => can('read', 'sales-customers');
  bool get canCreateCustomers => can('create', 'sales-customers');
  bool get canUpdateCustomers => can('update', 'sales-customers');
  bool get canDeleteCustomers => can('delete', 'sales-customers');

  bool get canViewVendors => can('read', 'purchases-vendors');
  bool get canCreateVendors => can('create', 'purchases-vendors');
  bool get canUpdateVendors => can('update', 'purchases-vendors');
  bool get canDeleteVendors => can('delete', 'purchases-vendors');

  /// Combined contacts access
  bool get canViewContacts => canViewCustomers || canViewVendors;
  bool get canCreateContacts => canCreateCustomers || canCreateVendors;

  /// Documents (Invoices/Bills)
  bool get canViewInvoices => can('read', 'sales-invoices');
  bool get canCreateInvoices => can('create', 'sales-invoices');
  bool get canUpdateInvoices => can('update', 'sales-invoices');
  bool get canDeleteInvoices => can('delete', 'sales-invoices');

  bool get canViewBills => can('read', 'purchases-bills');
  bool get canCreateBills => can('create', 'purchases-bills');
  bool get canUpdateBills => can('update', 'purchases-bills');
  bool get canDeleteBills => can('delete', 'purchases-bills');

  /// Combined documents access
  bool get canViewDocuments => canViewInvoices || canViewBills;
  bool get canCreateDocuments => canCreateInvoices || canCreateBills;

  /// Banking - Accounts
  bool get canViewAccounts => can('read', 'banking-accounts');
  bool get canCreateAccounts => can('create', 'banking-accounts');
  bool get canUpdateAccounts => can('update', 'banking-accounts');
  bool get canDeleteAccounts => can('delete', 'banking-accounts');

  /// Banking - Transactions
  bool get canViewTransactions => can('read', 'banking-transactions');
  bool get canCreateTransactions => can('create', 'banking-transactions');
  bool get canUpdateTransactions => can('update', 'banking-transactions');
  bool get canDeleteTransactions => can('delete', 'banking-transactions');

  /// Banking - Transfers
  bool get canViewTransfers => can('read', 'banking-transfers');
  bool get canCreateTransfers => can('create', 'banking-transfers');
  bool get canUpdateTransfers => can('update', 'banking-transfers');
  bool get canDeleteTransfers => can('delete', 'banking-transfers');

  /// Banking - Reconciliations
  bool get canViewReconciliations => can('read', 'banking-reconciliations');
  bool get canCreateReconciliations => can('create', 'banking-reconciliations');
  bool get canUpdateReconciliations => can('update', 'banking-reconciliations');
  bool get canDeleteReconciliations => can('delete', 'banking-reconciliations');

  /// Reports
  bool get canViewReports => can('read', 'common-reports');
  bool get canCreateReports => can('create', 'common-reports');

  /// Settings
  bool get canViewCategories => can('read', 'settings-categories');
  bool get canCreateCategories => can('create', 'settings-categories');
  bool get canUpdateCategories => can('update', 'settings-categories');
  bool get canDeleteCategories => can('delete', 'settings-categories');

  bool get canViewCurrencies => can('read', 'settings-currencies');
  bool get canCreateCurrencies => can('create', 'settings-currencies');
  bool get canUpdateCurrencies => can('update', 'settings-currencies');
  bool get canDeleteCurrencies => can('delete', 'settings-currencies');

  bool get canViewTaxes => can('read', 'settings-taxes');
  bool get canCreateTaxes => can('create', 'settings-taxes');
  bool get canUpdateTaxes => can('update', 'settings-taxes');
  bool get canDeleteTaxes => can('delete', 'settings-taxes');

  bool get canViewSettings => can('read', 'settings-settings');
  bool get canUpdateSettings => can('update', 'settings-settings');

  // ─── Menu Visibility ────────────────────────────────────────────────────────

  /// Drawer menu items visibility based on role.
  List<DrawerMenuItem> getVisibleMenuItems() {
    final items = <DrawerMenuItem>[];

    // Dashboard - everyone with admin panel access
    if (canAccessAdminPanel) {
      items.add(DrawerMenuItem.dashboard);
    }

    // Contacts
    if (canViewContacts) {
      items.add(DrawerMenuItem.contacts);
    }

    // Documents
    if (canViewDocuments) {
      items.add(DrawerMenuItem.documents);
    }

    // Banking section
    if (canViewAccounts) {
      items.add(DrawerMenuItem.accounts);
    }
    if (canViewTransactions) {
      items.add(DrawerMenuItem.transactions);
    }
    if (canViewTransfers) {
      items.add(DrawerMenuItem.transfers);
    }
    if (canViewReconciliations) {
      items.add(DrawerMenuItem.reconciliations);
    }

    // Users - admin only
    if (canViewUsers) {
      items.add(DrawerMenuItem.users);
    }

    // Reports
    if (canViewReports) {
      items.add(DrawerMenuItem.reports);
    }

    // Settings
    if (canViewCategories) {
      items.add(DrawerMenuItem.categories);
    }
    if (canViewCurrencies) {
      items.add(DrawerMenuItem.currencies);
    }
    if (canViewTaxes) {
      items.add(DrawerMenuItem.taxes);
    }

    return items;
  }

  /// Check if a specific menu item should be visible.
  bool isMenuItemVisible(DrawerMenuItem item) {
    switch (item) {
      case DrawerMenuItem.dashboard:
        return canAccessAdminPanel;
      case DrawerMenuItem.contacts:
        return canViewContacts;
      case DrawerMenuItem.documents:
        return canViewDocuments;
      case DrawerMenuItem.accounts:
        return canViewAccounts;
      case DrawerMenuItem.transactions:
        return canViewTransactions;
      case DrawerMenuItem.transfers:
        return canViewTransfers;
      case DrawerMenuItem.reconciliations:
        return canViewReconciliations;
      case DrawerMenuItem.users:
        return canViewUsers;
      case DrawerMenuItem.reports:
        return canViewReports;
      case DrawerMenuItem.categories:
        return canViewCategories;
      case DrawerMenuItem.currencies:
        return canViewCurrencies;
      case DrawerMenuItem.taxes:
        return canViewTaxes;
      case DrawerMenuItem.settings:
        return canViewSettings;
      case DrawerMenuItem.translations:
        return canAccessAdminPanel; // Only admin panel users
    }
  }

  // ─── Error Messages ─────────────────────────────────────────────────────────

  /// Get a user-friendly error message for permission denial.
  String getPermissionDeniedMessage(String resource) {
    if (!isAuthenticated) {
      return 'Please log in to access this feature.';
    }
    if (isClientPortalOnly) {
      return 'This feature is not available in the customer portal.';
    }
    return 'You do not have permission to access $resource. Contact your administrator.';
  }
}

/// Enum for drawer menu items.
enum DrawerMenuItem {
  dashboard,
  contacts,
  documents,
  accounts,
  transactions,
  transfers,
  reconciliations,
  users,
  reports,
  categories,
  currencies,
  taxes,
  settings,
  translations,
}

/// Extension for human-readable names.
extension DrawerMenuItemExtension on DrawerMenuItem {
  String get label {
    switch (this) {
      case DrawerMenuItem.dashboard:
        return 'Dashboard';
      case DrawerMenuItem.contacts:
        return 'Contacts';
      case DrawerMenuItem.documents:
        return 'Documents';
      case DrawerMenuItem.accounts:
        return 'Accounts';
      case DrawerMenuItem.transactions:
        return 'Transactions';
      case DrawerMenuItem.transfers:
        return 'Transfers';
      case DrawerMenuItem.reconciliations:
        return 'Reconciliations';
      case DrawerMenuItem.users:
        return 'Users';
      case DrawerMenuItem.reports:
        return 'Reports';
      case DrawerMenuItem.categories:
        return 'Categories';
      case DrawerMenuItem.currencies:
        return 'Currencies';
      case DrawerMenuItem.taxes:
        return 'Taxes';
      case DrawerMenuItem.settings:
        return 'Settings';
      case DrawerMenuItem.translations:
        return 'Translations';
    }
  }

  IconData get icon {
    switch (this) {
      case DrawerMenuItem.dashboard:
        return Icons.speed;
      case DrawerMenuItem.contacts:
        return Icons.contacts;
      case DrawerMenuItem.documents:
        return Icons.description;
      case DrawerMenuItem.accounts:
        return Icons.account_balance_wallet;
      case DrawerMenuItem.transactions:
        return Icons.swap_horiz;
      case DrawerMenuItem.transfers:
        return Icons.compare_arrows;
      case DrawerMenuItem.reconciliations:
        return Icons.receipt_long;
      case DrawerMenuItem.users:
        return Icons.people;
      case DrawerMenuItem.reports:
        return Icons.bar_chart;
      case DrawerMenuItem.categories:
        return Icons.category;
      case DrawerMenuItem.currencies:
        return Icons.currency_exchange;
      case DrawerMenuItem.taxes:
        return Icons.percent;
      case DrawerMenuItem.settings:
        return Icons.settings;
      case DrawerMenuItem.translations:
        return Icons.translate;
    }
  }
}
