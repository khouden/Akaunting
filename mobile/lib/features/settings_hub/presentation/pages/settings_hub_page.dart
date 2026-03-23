import 'package:flutter/material.dart';
import '../../../categories/presentation/pages/categories_list_page.dart';
import '../../../currencies/presentation/pages/currencies_list_page.dart';
import '../../../taxes/presentation/pages/taxes_list_page.dart';
import '../../../settings/presentation/pages/settings_list_page.dart';
import '../../../translations/presentation/pages/translations_page.dart';

class SettingsHubPage extends StatelessWidget {
  const SettingsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Configuration'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure your application',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _SettingsCard(
                    icon: Icons.category,
                    label: 'Categories',
                    subtitle: 'Organize items',
                    color: const Color(0xFF00D084),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesListPage())),
                  ),
                  _SettingsCard(
                    icon: Icons.currency_exchange,
                    label: 'Currencies',
                    subtitle: 'Exchange rates',
                    color: const Color(0xFF3B82F6),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrenciesListPage())),
                  ),
                  _SettingsCard(
                    icon: Icons.percent,
                    label: 'Taxes',
                    subtitle: 'Tax rates',
                    color: const Color(0xFFF59E0B),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxesListPage())),
                  ),
                  _SettingsCard(
                    icon: Icons.settings,
                    label: 'Settings',
                    subtitle: 'App configuration',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsListPage())),
                  ),
                  _SettingsCard(
                    icon: Icons.translate,
                    label: 'Translations',
                    subtitle: 'Language files',
                    color: const Color(0xFFEF4444),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TranslationsPage())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SettingsCard({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color.withValues(alpha: 0.2))),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
