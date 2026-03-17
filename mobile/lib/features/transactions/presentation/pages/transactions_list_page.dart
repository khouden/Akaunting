import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/ui/components/akaunting_search.dart';
import '../../../../core/ui/components/badge.dart';
import '../../../../core/ui/components/cards/card.dart';
import '../../../../core/ui/components/base_alert.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';
import 'transaction_form_page.dart';
import 'transaction_detail_page.dart';

class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({super.key});

  @override
  State<TransactionsListPage> createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  late TransactionCubit _cubit;
  String _search = '';
  String _tab = 'all';

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<TransactionCubit>()..fetchTransactions(query: _buildQuery());
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'key': 'all', 'label': 'All'},
      {'key': 'income', 'label': 'Income'},
      {'key': 'expense', 'label': 'Expense'},
    ];

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          title: const Text('Transactions', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: BlocConsumer<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state is TransactionOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              _cubit.fetchTransactions(query: _buildQuery());
            } else if (state is TransactionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionLoaded) {
              final incomes = state.transactions.where((t) => t.type == 'income');
              final expenses = state.transactions.where((t) => t.type == 'expense');

              return RefreshIndicator(
                onRefresh: () => _cubit.fetchTransactions(query: _buildQuery()),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Incomes', style: TextStyle(color: Colors.black54)),
                                const SizedBox(height: 6),
                                Text('${incomes.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Expenses', style: TextStyle(color: Colors.black54)),
                                const SizedBox(height: 6),
                                Text('${expenses.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AkauntingSearch(
                      placeholder: 'Search transactions...',
                      onSearch: (value) {
                        _search = value;
                        _cubit.fetchTransactions(query: _buildQuery());
                      },
                      onClear: () {
                        _search = '';
                        _cubit.fetchTransactions(query: _buildQuery());
                      },
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: tabs.map((tab) {
                          final selected = _tab == tab['key'];

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(tab['label']!),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  _tab = tab['key']!;
                                });
                                _cubit.fetchTransactions(query: _buildQuery());
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.transactions.isEmpty)
                      const BaseAlert(
                        type: AlertType.info,
                        icon: Icons.info_outline,
                        content: Text('No transactions found'),
                      ),
                    ...state.transactions.map((transaction) {
                      final isIncome = transaction.type == 'income';
                      final color = isIncome ? Colors.green : Colors.red;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          hover: true,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionDetailPage(transactionId: transaction.id),
                                ),
                              ).then((_) => _cubit.fetchTransactions(query: _buildQuery()));
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color.withValues(alpha: 0.15),
                                  child: Icon(
                                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction.description ?? transaction.type.toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(transaction.paidAt, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    AppBadge(
                                      type: isIncome ? BadgeType.success : BadgeType.danger,
                                      rounded: true,
                                      child: Text(isIncome ? 'INCOME' : 'EXPENSE'),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      transaction.amountFormatted ?? transaction.amount.toString(),
                                      style: TextStyle(fontWeight: FontWeight.bold, color: color),
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
          heroTag: 'transactions_fab',
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TransactionFormPage(),
              ),
            ).then((_) => _cubit.fetchTransactions(query: _buildQuery()));
          },
        ),
      ),
    );
  }

  Map<String, dynamic> _buildQuery() {
    final query = <String, dynamic>{};
    final searchParts = <String>[];

    if (_tab == 'income') {
      searchParts.add('type:income');
    } else if (_tab == 'expense') {
      searchParts.add('type:expense');
    }

    if (_search.trim().isNotEmpty) {
      searchParts.add(_search.trim());
    }

    if (searchParts.isNotEmpty) {
      query['search'] = searchParts.join(' ');
    }

    return query;
  }
}
