import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';
import 'transaction_form_page.dart';

class TransactionDetailPage extends StatefulWidget {
  final int transactionId;

  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late TransactionCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<TransactionCubit>()..fetchTransaction(widget.transactionId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction Details', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          actions: [
            BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                if (state is TransactionDetailLoaded) {
                  return IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionFormPage(transaction: state.transaction),
                        ),
                      ).then((_) => _cubit.fetchTransaction(widget.transactionId));
                    },
                  );
                }
                return const SizedBox();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _cubit.deleteTransaction(widget.transactionId);
              },
            ),
          ],
        ),
        body: BlocConsumer<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state is TransactionOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              Navigator.pop(context);
            } else if (state is TransactionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TransactionDetailLoaded) {
              final trx = state.transaction;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Amount', trx.amountFormatted ?? trx.amount.toString(),
                      valueColor: trx.type == 'income' ? Colors.green : Colors.red,
                      isBig: true,
                    ),
                    const Divider(height: 32),
                    _buildDetailRow('Type', trx.type.toUpperCase()),
                    const SizedBox(height: 16),
                    _buildDetailRow('Paid At', trx.paidAt),
                    const SizedBox(height: 16),
                    _buildDetailRow('Description', trx.description ?? '-'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Account ID', trx.accountId?.toString() ?? '-'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Category ID', trx.categoryId?.toString() ?? '-'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Payment Method', trx.paymentMethod ?? '-'),
                    const SizedBox(height: 16),
                    _buildDetailRow('Reference', trx.reference ?? '-'),
                  ],
                ),
              );
            }
            return const Center(child: Text('Transaction details not available.'));
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isBig = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBig ? FontWeight.bold : FontWeight.w600,
            fontSize: isBig ? 24 : 16,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
