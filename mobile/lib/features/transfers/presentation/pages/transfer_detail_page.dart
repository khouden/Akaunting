import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/ui/components/cards/card.dart';
import '../cubit/transfer_cubit.dart';
import '../cubit/transfer_state.dart';
import 'transfer_form_page.dart';

class TransferDetailPage extends StatefulWidget {
  final int transferId;

  const TransferDetailPage({super.key, required this.transferId});

  @override
  State<TransferDetailPage> createState() => _TransferDetailPageState();
}

class _TransferDetailPageState extends State<TransferDetailPage> {
  late TransferCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<TransferCubit>()..fetchTransfer(widget.transferId);
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
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          title: const Text('Transfer Details', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            BlocBuilder<TransferCubit, TransferState>(
              builder: (context, state) {
                if (state is! TransferDetailLoaded) {
                  return const SizedBox.shrink();
                }

                return IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransferFormPage(existing: state.transfer),
                      ),
                    ).then((_) => _cubit.fetchTransfer(widget.transferId));
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _cubit.deleteTransfer(widget.transferId);
              },
            ),
          ],
        ),
        body: BlocConsumer<TransferCubit, TransferState>(
          listener: (context, state) {
            if (state is TransferOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              Navigator.pop(context);
            } else if (state is TransferError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is TransferLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TransferDetailLoaded) {
              final transfer = state.transfer;
              final paidDate = transfer.paidAt.contains('T')
                  ? transfer.paidAt.split('T').first
                  : transfer.paidAt;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row('From Account', transfer.fromAccount),
                        const SizedBox(height: 12),
                        _row('To Account', transfer.toAccount),
                        const SizedBox(height: 12),
                        _row('Date', paidDate),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: _row(
                      'Amount',
                      transfer.amountFormatted ?? transfer.amount.toStringAsFixed(2),
                      emphasize: true,
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Transfer details not available.'));
          },
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
            fontSize: emphasize ? 20 : 16,
          ),
        ),
      ],
    );
  }
}
