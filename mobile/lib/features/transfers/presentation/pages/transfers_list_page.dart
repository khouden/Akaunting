import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/ui/components/akaunting_search.dart';
import '../../../../core/ui/components/base_alert.dart';
import '../../../../core/ui/components/badge.dart';
import '../../../../core/ui/components/cards/card.dart';
import '../cubit/transfer_cubit.dart';
import '../cubit/transfer_state.dart';
import 'transfer_detail_page.dart';
import 'transfer_form_page.dart';

class TransfersListPage extends StatefulWidget {
  const TransfersListPage({super.key});

  @override
  State<TransfersListPage> createState() => _TransfersListPageState();
}

class _TransfersListPageState extends State<TransfersListPage> {
  late TransferCubit _cubit;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<TransferCubit>()..fetchTransfers();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _cubit.fetchTransfers(query: _buildQuery());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          title: const Text('Transfers', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocConsumer<TransferCubit, TransferState>(
          listener: (context, state) {
            if (state is TransferOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              _cubit.fetchTransfers(query: _buildQuery());
            } else if (state is TransferError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is TransferLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TransferLoaded) {
              final total = state.transfers.fold<double>(0, (sum, item) => sum + item.amount);

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Transfers', style: TextStyle(color: Colors.black54)),
                          const SizedBox(height: 6),
                          Text(
                            total.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AkauntingSearch(
                      placeholder: 'Search transfers...',
                      onSearch: (value) {
                        _search = value;
                        _cubit.fetchTransfers(query: _buildQuery());
                      },
                      onClear: () {
                        _search = '';
                        _cubit.fetchTransfers(query: _buildQuery());
                      },
                    ),
                    const SizedBox(height: 12),
                    if (state.transfers.isEmpty)
                      const BaseAlert(
                        type: AlertType.info,
                        icon: Icons.info_outline,
                        content: Text('No transfers found'),
                      ),
                    ...state.transfers.map((transfer) {
                      final paidDate = transfer.paidAt.contains('T')
                          ? transfer.paidAt.split('T').first
                          : transfer.paidAt;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          hover: true,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransferDetailPage(transferId: transfer.id),
                                ),
                              ).then((_) => _cubit.fetchTransfers(query: _buildQuery()));
                            },
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0x14006CFF),
                                  child: Icon(Icons.swap_horiz, color: Color(0xFF006CFF)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${transfer.fromAccount} -> ${transfer.toAccount}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(paidDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const AppBadge(
                                      type: BadgeType.info,
                                      rounded: true,
                                      child: Text('TRANSFER'),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      transfer.amountFormatted ?? transfer.amount.toStringAsFixed(2),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'transfers_fab',
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TransferFormPage(),
              ),
            ).then((_) => _cubit.fetchTransfers(query: _buildQuery()));
          },
        ),
      ),
    );
  }

  Map<String, dynamic> _buildQuery() {
    if (_search.trim().isEmpty) {
      return {};
    }

    return {'search': _search.trim()};
  }
}
