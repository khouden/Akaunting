import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/cubits/auth_cubit.dart';
import '../../../features/accounts/presentation/pages/accounts_list_page.dart';
import '../../../features/transactions/presentation/pages/transactions_list_page.dart';
import '../../../features/transfers/presentation/pages/transfers_list_page.dart';
import '../../../features/reconciliations/presentation/pages/reconciliations_list_page.dart';
import '../../../features/reports/presentation/pages/reports_list_page.dart';
import '../../../features/categories/presentation/pages/categories_list_page.dart';
import '../../../features/currencies/presentation/pages/currencies_list_page.dart';
import '../../../features/taxes/presentation/pages/taxes_list_page.dart';
import '../../../features/translations/presentation/pages/translations_page.dart';
import '../../../features/auth/presentation/pages/auth_check_page.dart';

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

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 12),
                  Text(
                    'Akaunting',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Mobile',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Dashboard
            _DrawerItem(
              icon: Icons.speed,
              label: 'Dashboard',
              selected: currentIndex == 0,
              onTap: () {
                Navigator.pop(context);
                onTabSelected(0);
              },
            ),

            // Banking section
            _DrawerSectionHeader(label: 'Banking'),
            _DrawerItem(
              icon: Icons.account_balance_wallet,
              label: 'Accounts',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountsListPage()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.swap_horiz,
              label: 'Transactions',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TransactionsListPage()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.compare_arrows,
              label: 'Transfers',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransfersListPage()),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.receipt_long,
              label: 'Reconciliations',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ReconciliationsListPage()),
                );
              },
            ),

            // Reports
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

            // Settings section
            _DrawerSectionHeader(label: 'Configuration'),
            _DrawerItem(
              icon: Icons.settings,
              label: 'Settings Hub',
              selected: currentIndex == 3,
              onTap: () {
                Navigator.pop(context);
                onTabSelected(3);
              },
            ),
            _DrawerItem(
              icon: Icons.category,
              label: 'Categories',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const CategoriesListPage(),
                ));
              },
            ),
            _DrawerItem(
              icon: Icons.currency_exchange,
              label: 'Currencies',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const CurrenciesListPage(),
                ));
              },
            ),
            _DrawerItem(
              icon: Icons.percent,
              label: 'Taxes',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const TaxesListPage(),
                ));
              },
            ),
            _DrawerItem(
              icon: Icons.translate,
              label: 'Translations',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const TranslationsPage(),
                ));
              },
            ),

            const Spacer(),
            const Divider(height: 1),

            // Logout
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
    final color = iconColor ?? (selected ? theme.colorScheme.primary : theme.colorScheme.onSurface);

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
