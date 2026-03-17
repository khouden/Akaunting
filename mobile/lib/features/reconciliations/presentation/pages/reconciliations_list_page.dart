import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/ui/components/akaunting_search.dart';
import '../../../../core/ui/components/badge.dart';
import '../../../../core/ui/components/cards/card.dart';
import '../../../../core/ui/components/base_alert.dart';
import '../../../../logic/cubits/reconciliation_cubit.dart';
import 'reconciliation_detail_page.dart';
import 'reconciliation_form_page.dart';

class ReconciliationsListPage extends StatelessWidget {
  const ReconciliationsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReconciliationCubit>(
      create: (context) => sl<ReconciliationCubit>()..loadReconciliations(),
      child: const ReconciliationsListView(),
    );
  }
}

class ReconciliationsListView extends StatefulWidget {
  const ReconciliationsListView({super.key});

  @override
  State<ReconciliationsListView> createState() => _ReconciliationsListViewState();
}

class _ReconciliationsListViewState extends State<ReconciliationsListView> {
  String _searchQuery = '';

  Future<void> _onRefresh() async {
    context.read<ReconciliationCubit>().loadReconciliations(search: _searchQuery);
  }

  void _onSearch(String value) {
    setState(() {
      _searchQuery = value;
    });
    context.read<ReconciliationCubit>().loadReconciliations(search: value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Reconciliations', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'reconciliations_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ReconciliationFormPage(),
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
              placeholder: 'Search reconciliations...',
              onSearch: _onSearch,
              onClear: () => _onSearch(''),
            ),
          ),
          Expanded(
            child: BlocBuilder<ReconciliationCubit, ReconciliationState>(
              builder: (context, state) {
                if (state is ReconciliationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReconciliationError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BaseAlert(
                      type: AlertType.danger,
                      content: Text(state.message),
                      icon: Icons.error_outline,
                    ),
                  );
                } else if (state is ReconciliationsLoaded) {
                  if (state.reconciliations.isEmpty) {
                    return const Center(child: Text('No reconciliations found.'));
                  }
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.reconciliations.length,
                      itemBuilder: (context, index) {
                        final rec = state.reconciliations[index];
                        final startDate = rec.startedAt.split('T').first;
                        final endDate = rec.endedAt.split('T').first;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppCard(
                            hover: true,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ReconciliationDetailPage(reconciliation: rec),
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
                                              rec.account?.name ?? 'Account #${rec.accountId}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            AppBadge(
                                              type: rec.reconciled ? BadgeType.success : BadgeType.warning,
                                              child: Text(rec.reconciled ? 'Reconciled' : 'Unreconciled'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$startDate - $endDate',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    rec.closingBalanceFormatted ?? 
                                        '\$${rec.closingBalance.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
