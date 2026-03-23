import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/ui/components/akaunting_select.dart';
import '../../../../core/ui/components/base_alert.dart';
import '../../../../core/ui/components/base_button.dart';
import '../../../../core/ui/components/cards/card.dart';
import '../../../../core/ui/components/inputs/base_input.dart';
import '../../../../data/models/transfer_model.dart';
import '../../../../domain/repositories/transfer_repository.dart';
import '../cubit/transfer_cubit.dart';
import '../cubit/transfer_state.dart';

class TransferFormPage extends StatefulWidget {
  final TransferModel? existing;

  const TransferFormPage({super.key, this.existing});

  @override
  State<TransferFormPage> createState() => _TransferFormPageState();
}

class _TransferFormPageState extends State<TransferFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TransferCubit _cubit;
  late TransferRepository _repository;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController(
    text: 'offline-payments.cash.1',
  );

  int? _fromAccountId;
  int? _toAccountId;
  bool _loadingLookups = true;
  String? _lookupError;
  List<LookupOption> _accounts = [];

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<TransferCubit>();
    _repository = GetIt.I<TransferRepository>();

    if (widget.existing != null) {
      final transfer = widget.existing!;
      _fromAccountId = transfer.fromAccountId;
      _toAccountId = transfer.toAccountId;
      _amountController.text = transfer.amount.toString();
      _dateController.text = transfer.paidAt.contains('T')
          ? transfer.paidAt.split('T').first
          : transfer.paidAt;
    } else {
      _dateController.text = DateTime.now().toIso8601String().split('T').first;
    }

    _loadLookups();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _paymentMethodController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    setState(() {
      _loadingLookups = true;
      _lookupError = null;
    });

    try {
      _accounts = await _repository.getAccounts();

      if (_accounts.length < 2) {
        _lookupError = 'At least two accounts are required to create a transfer.';
      }

      _fromAccountId ??= _accounts.isNotEmpty ? _accounts.first.id : null;
      _toAccountId ??= _accounts.length > 1 ? _accounts[1].id : _fromAccountId;
    } catch (e) {
      _lookupError = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _loadingLookups = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          title: Text(
            widget.existing == null ? 'New Transfer' : 'Edit Transfer',
            style: const TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: BlocConsumer<TransferCubit, TransferState>(
          listener: (context, state) {
            if (state is TransferOperationSuccess) {
              Navigator.pop(context, true);
            } else if (state is TransferError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is TransferLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_lookupError != null)
                      BaseAlert(
                        type: AlertType.warning,
                        icon: Icons.warning_amber_rounded,
                        content: Text(_lookupError!),
                      ),
                    AppCard(
                      child: Column(
                        children: [
                          AkauntingSelect(
                            title: 'From Account',
                            isRequired: true,
                            options: _accounts
                                .map((item) => AkauntingSelectOption(
                                      key: item.id.toString(),
                                      value: item.name,
                                    ))
                                .toList(),
                            value: _fromAccountId?.toString(),
                            onChanged: _loadingLookups
                                ? null
                                : (val) => setState(() => _fromAccountId = int.tryParse(val ?? '')),
                          ),
                          const SizedBox(height: 16),
                          AkauntingSelect(
                            title: 'To Account',
                            isRequired: true,
                            options: _accounts
                                .map((item) => AkauntingSelectOption(
                                      key: item.id.toString(),
                                      value: item.name,
                                    ))
                                .toList(),
                            value: _toAccountId?.toString(),
                            onChanged: _loadingLookups
                                ? null
                                : (val) => setState(() => _toAccountId = int.tryParse(val ?? '')),
                          ),
                          const SizedBox(height: 16),
                          BaseInput(
                            controller: _dateController,
                            label: 'Transfer Date',
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          BaseInput(
                            controller: _amountController,
                            label: 'Amount',
                            isRequired: true,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          const SizedBox(height: 16),
                          BaseInput(
                            controller: _descriptionController,
                            label: 'Description',
                          ),
                          const SizedBox(height: 16),
                          BaseInput(
                            controller: _referenceController,
                            label: 'Reference',
                          ),
                          const SizedBox(height: 16),
                          BaseInput(
                            controller: _paymentMethodController,
                            label: 'Payment Method Code',
                            isRequired: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: BaseButton(
                        onPressed: (isLoading || _loadingLookups) ? null : _save,
                        type: ButtonType.primary,
                        loading: isLoading,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fromAccountId == null || _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both accounts are required'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('From and To accounts must be different'), backgroundColor: Colors.red),
      );
      return;
    }

    final data = {
      'from_account_id': _fromAccountId,
      'to_account_id': _toAccountId,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'transferred_at': _dateController.text,
      'payment_method': _paymentMethodController.text.trim().isEmpty
          ? 'offline-payments.cash.1'
          : _paymentMethodController.text.trim(),
      'description': _descriptionController.text.trim(),
      'reference': _referenceController.text.trim(),
    };

    if (widget.existing == null) {
      _cubit.createTransfer(data);
    } else {
      _cubit.updateTransfer(widget.existing!.id, data);
    }
  }
}
