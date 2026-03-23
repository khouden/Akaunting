import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/ui/components/akaunting_search.dart';
import '../../../../core/ui/components/badge.dart';
import '../../../../core/ui/components/cards/card.dart';
import '../../../../core/ui/components/base_alert.dart';
import '../../../../logic/cubits/dashboard_cubit.dart';
import 'dashboard_form_page.dart';
import 'dashboard_detail_page.dart';

class DashboardsListPage extends StatelessWidget {
  const DashboardsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (context) => sl<DashboardCubit>()..loadDashboards(),
      child: const DashboardsListView(),
    );
  }
}

class DashboardsListView extends StatefulWidget {
  const DashboardsListView({super.key});

  @override
  State<DashboardsListView> createState() => _DashboardsListViewState();
}

class _DashboardsListViewState extends State<DashboardsListView> {
  String _searchQuery = '';

  Future<void> _onRefresh() async {
    context.read<DashboardCubit>().loadDashboards(search: _searchQuery);
  }

  void _onSearch(String value) {
    setState(() {
      _searchQuery = value;
    });
    context.read<DashboardCubit>().loadDashboards(search: value);
  }

  void _toggleDashboard(int id, bool currentlyEnabled) {
    if (currentlyEnabled) {
      context.read<DashboardCubit>().disableDashboard(id).then((_) {
        _onRefresh();
      });
    } else {
      context.read<DashboardCubit>().enableDashboard(id).then((_) {
        _onRefresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Dashboards', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboards_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DashboardFormPage(),
            ),
          ).then((_) => _onRefresh());
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: AkauntingSearch(
              placeholder: 'Search dashboards...',
              onSearch: _onSearch,
              onClear: () => _onSearch(''),
            ),
          ),
          Expanded(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DashboardError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BaseAlert(
                      type: AlertType.danger,
                      content: Text(state.message),
                      icon: Icons.error_outline,
                    ),
                  );
                } else if (state is DashboardsLoaded) {
                  if (state.dashboards.isEmpty) {
                    return const Center(child: Text('No dashboards found.'));
                  }
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.dashboards.length,
                      itemBuilder: (context, index) {
                        final dashboard = state.dashboards[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppCard(
                            hover: true,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DashboardDetailPage(dashboard: dashboard),
                                  ),
                                ).then((_) => _onRefresh());
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              dashboard.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            if (!dashboard.enabled) ...[
                                              const SizedBox(width: 8),
                                              const AppBadge(
                                                type: BadgeType.danger,
                                                child: Text('Disabled'),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      dashboard.enabled ? Icons.toggle_on : Icons.toggle_off,
                                      color: dashboard.enabled ? Colors.green : Colors.grey,
                                      size: 32,
                                    ),
                                    onPressed: () => _toggleDashboard(dashboard.id, dashboard.enabled),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
