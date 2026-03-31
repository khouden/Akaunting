import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/cubits/auth_cubit.dart';
import '../../../core/auth/permission_service.dart';
import '../../../features/accounts/presentation/pages/accounts_list_page.dart';
import '../../../features/transactions/presentation/pages/transactions_list_page.dart';
import '../../../features/transfers/presentation/pages/transfers_list_page.dart';
import '../../../features/reconciliations/presentation/pages/reconciliations_list_page.dart';
import '../../../features/categories/presentation/pages/categories_list_page.dart';
import '../../../features/currencies/presentation/pages/currencies_list_page.dart';
import '../../../features/taxes/presentation/pages/taxes_list_page.dart';
import '../../../features/contacts/presentation/pages/contacts_page.dart';
import '../../../features/documents/presentation/pages/documents_list_page.dart';
import '../../../features/translations/presentation/pages/translations_page.dart';
import '../../../features/auth/presentation/pages/auth_check_page.dart';
import '../../../features/users/presentation/pages/users_list_page.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Get permissions from auth state
        final permissions = authState is Authenticated
            ? authState.permissions
            : PermissionService();

        final user = authState is Authenticated ? authState.user : null;

        return Drawer(
          child: SafeArea(
            child: Column(
              children: [
                // Header with user info
                _DrawerHeader(
                  theme: theme,
                  userName: user?.name ?? 'User',
                  userEmail: user?.email ?? '',
                  userRole: _getPrimaryRole(user?.roles ?? []),
                ),

                // Scrollable list of items
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Dashboard - always visible for admin panel users
                        if (permissions.canAccessAdminPanel)
                          _DrawerItem(
                            icon: Icons.speed,
                            label: 'Dashboard',
                            selected: currentIndex == 0,
                            onTap: () {
                              Navigator.pop(context);
                              onTabSelected(0);
                            },
                          ),

                        // Contacts - based on customer/vendor permissions
                        if (permissions.canViewContacts)
                          _DrawerItem(
                            icon: Icons.contacts,
                            label: 'Contacts',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ContactsListPage(),
                                  ));
                            },
                          ),

                        // Documents - based on invoice/bill permissions
                        if (permissions.canViewDocuments)
                          _DrawerItem(
                            icon: Icons.description,
                            label: 'Documents',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DocumentsListPage(),
                                  ));
                            },
                          ),

                        // Banking section - show header only if any banking permission exists
                        if (_hasBankingAccess(permissions)) ...[
                          _DrawerSectionHeader(label: 'Banking'),
                          if (permissions.canViewAccounts)
                            _DrawerItem(
                              icon: Icons.account_balance_wallet,
                              label: 'Accounts',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AccountsListPage()),
                                );
                              },
                            ),
                          if (permissions.canViewTransactions)
                            _DrawerItem(
                              icon: Icons.swap_horiz,
                              label: 'Transactions',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const TransactionsListPage()),
                                );
                              },
                            ),
                          if (permissions.canViewTransfers)
                            _DrawerItem(
                              icon: Icons.compare_arrows,
                              label: 'Transfers',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const TransfersListPage()),
                                );
                              },
                            ),
                          if (permissions.canViewReconciliations)
                            _DrawerItem(
                              icon: Icons.receipt_long,
                              label: 'Reconciliations',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ReconciliationsListPage()),
                                );
                              },
                            ),
                        ],

                        // Team section - admin only
                        if (permissions.canViewUsers) ...[
                          _DrawerSectionHeader(label: 'Team'),
                          _DrawerItem(
                            icon: Icons.people,
                            label: 'Users',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const UsersListPage()),
                              );
                            },
                          ),
                        ],

                        // Reports section
                        if (permissions.canViewReports) ...[
                          _DrawerSectionHeader(label: 'Analytics'),
                          _DrawerItem(
                            icon: Icons.bar_chart,
                            label: 'Reports',
                            selected: currentIndex == 2,
                            onTap: () {
                              Navigator.pop(context);
                              onTabSelected(2);
                            },
                          ),
                        ],

                        // Settings section - show header only if any setting permission exists
                        if (_hasSettingsAccess(permissions)) ...[
                          _DrawerSectionHeader(label: 'Configuration'),
                          if (permissions.canAccessAdminPanel)
                            _DrawerItem(
                              icon: Icons.settings,
                              label: 'Settings Hub',
                              selected: currentIndex == 3,
                              onTap: () {
                                Navigator.pop(context);
                                onTabSelected(3);
                              },
                            ),
                          if (permissions.canViewCategories)
                            _DrawerItem(
                              icon: Icons.category,
                              label: 'Categories',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CategoriesListPage(),
                                    ));
                              },
                            ),
                          if (permissions.canViewCurrencies)
                            _DrawerItem(
                              icon: Icons.currency_exchange,
                              label: 'Currencies',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CurrenciesListPage(),
                                    ));
                              },
                            ),
                          if (permissions.canViewTaxes)
                            _DrawerItem(
                              icon: Icons.percent,
                              label: 'Taxes',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TaxesListPage(),
                                    ));
                              },
                            ),
                          if (permissions.canAccessAdminPanel)
                            _DrawerItem(
                              icon: Icons.translate,
                              label: 'Translations',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TranslationsPage(),
                                    ));
                              },
                            ),
                        ],
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1),

                // Logout - always visible
                _DrawerItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AuthCubit>().logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthCheckPage()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _hasBankingAccess(PermissionService permissions) {
    return permissions.canViewAccounts ||
        permissions.canViewTransactions ||
        permissions.canViewTransfers ||
        permissions.canViewReconciliations;
  }

  bool _hasSettingsAccess(PermissionService permissions) {
    return permissions.canAccessAdminPanel ||
        permissions.canViewCategories ||
        permissions.canViewCurrencies ||
        permissions.canViewTaxes;
  }

  String _getPrimaryRole(List<String> roles) {
    if (roles.contains('admin')) return 'Administrator';
    if (roles.contains('manager')) return 'Manager';
    if (roles.contains('accountant')) return 'Accountant';
    if (roles.contains('customer')) return 'Customer';
    if (roles.isEmpty) return 'User';
    return roles.first.substring(0, 1).toUpperCase() + roles.first.substring(1);
  }
}

class _DrawerHeader extends StatelessWidget {
  final ThemeData theme;
  final String userName;
  final String userEmail;
  final String userRole;

  const _DrawerHeader({
    required this.theme,
    required this.userName,
    required this.userEmail,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const Spacer(),
              // Role badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(userRole).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getRoleColor(userRole).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  userRole,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getRoleColor(userRole),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Akaunting',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (userName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              userName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
          if (userEmail.isNotEmpty)
            Text(
              userEmail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'administrator':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'accountant':
        return Colors.blue;
      case 'customer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _DrawerSectionHeader extends StatelessWidget {
  final String label;
  const _DrawerSectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? iconColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ??
        (selected ? theme.colorScheme.primary : theme.colorScheme.onSurface);

    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      onTap: onTap,
    );
  }
}
