import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/ui/components/badge.dart';
import '../../../../core/ui/components/base_button.dart';
import '../../../../core/ui/components/cards/card.dart';
import '../../../../core/ui/components/base_alert.dart';
import '../../../../data/models/reconciliation_model.dart';
import '../../../../logic/cubits/reconciliation_cubit.dart';
import 'reconciliation_form_page.dart';

class ReconciliationDetailPage extends StatelessWidget {
  final ReconciliationModel reconciliation;

  const ReconciliationDetailPage({super.key, required this.reconciliation});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReconciliationCubit>(
      create: (context) => sl<ReconciliationCubit>(),
      child: ReconciliationDetailView(reconciliation: reconciliation),
    );
  }
}

class ReconciliationDetailView extends StatefulWidget {
  final ReconciliationModel reconciliation;

  const ReconciliationDetailView({super.key, required this.reconciliation});

  @override
  State<ReconciliationDetailView> createState() => _ReconciliationDetailViewState();
}

class _ReconciliationDetailViewState extends State<ReconciliationDetailView> {
  late ReconciliationModel _reconciliation;

  @override
  void initState() {
    super.initState();
    _reconciliation = widget.reconciliation;
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this reconciliation? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<ReconciliationCubit>().deleteReconciliation(_reconciliation.id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReconciliationCubit, ReconciliationState>(
      listener: (context, state) {
        if (state is ReconciliationDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reconciliation deleted successfully')),
          );
          Navigator.of(context).pop();
        } else if (state is ReconciliationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is ReconciliationLoaded) {
          setState(() {
            _reconciliation = state.reconciliation;
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is ReconciliationLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          appBar: AppBar(
            title: const Text('Reconciliation Details', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReconciliationFormPage(reconciliation: _reconciliation),
                    ),
                  ).then((success) {
                    if (success == true) {
                      context.read<ReconciliationCubit>().loadReconciliation(_reconciliation.id);
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: isLoading ? null : _confirmDelete,
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Account',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                ),
                                Text(
                                  _reconciliation.account?.name ?? 'Account #${_reconciliation.accountId}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                ),
                                AppBadge(
                                  type: _reconciliation.reconciled ? BadgeType.success : BadgeType.warning,
                                  child: Text(_reconciliation.reconciled ? 'Reconciled' : 'Unreconciled'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Period',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Started At',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                ),
                                Text(
                                  _reconciliation.startedAt.split('T').first,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ended At',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                ),
                                Text(
                                  _reconciliation.endedAt.split('T').first,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Closing Balance',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _reconciliation.closingBalanceFormatted ?? '\$${_reconciliation.closingBalance.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
