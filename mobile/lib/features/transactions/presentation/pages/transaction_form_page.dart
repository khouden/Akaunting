import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/ui/components/base_alert.dart';
import '../../../../core/ui/components/base_button.dart';
import '../../../../core/ui/components/inputs/base_input.dart';
import '../../../../core/ui/components/akaunting_select.dart';
import '../../../../core/ui/components/cards/card.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../domain/repositories/transaction_repository.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';

class TransactionFormPage extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionFormPage({super.key, this.transaction});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TransactionCubit _cubit;
  late TransactionRepository _repository;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  String _type = 'expense';
  int? _accountId;
  int? _categoryId;
  int? _contactId;
  String _paymentMethod = 'offline.cash';
  bool _loadingLookups = true;
  String? _lookupError;

  List<LookupOption> _accounts = [];
  List<LookupOption> _categories = [];
  List<LookupOption> _contacts = [];

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<TransactionCubit>();
    _repository = GetIt.I<TransactionRepository>();

    if (widget.transaction != null) {
      final trx = widget.transaction!;
      _type = trx.type;
      _amountController.text = trx.amount.toString();
      _dateController.text = trx.paidAt.split(' ').first;
      _descriptionController.text = trx.description ?? '';
      _referenceController.text = trx.reference ?? '';
      _numberController.text = trx.number ?? '';
      _accountId = trx.accountId;
      _categoryId = trx.categoryId;
      _contactId = trx.contactId;
      if (trx.paymentMethod != null) {
        _paymentMethod = trx.paymentMethod!;
      }
    } else {
      _dateController.text = DateTime.now().toString().split(' ').first;
      _numberController.text = 'TRX-${DateTime.now().millisecondsSinceEpoch}';
    }

    _loadLookups();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _numberController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    setState(() {
      _loadingLookups = true;
      _lookupError = null;
    });

    try {
      final typeForContacts = _type == 'income' ? 'customer' : 'vendor';
      final results = await Future.wait<List<LookupOption>>([
        _repository.getAccounts(),
        _repository.getCategories(type: _type),
        _repository.getContacts(type: typeForContacts),
      ]);

      _accounts = results[0];
      _categories = results[1];
      _contacts = results[2];

      if (_accounts.isEmpty) {
        final account = await _repository.createDefaultAccount();
        _accounts = [account];
      }

      if (_categories.isEmpty) {
        final category = await _repository.createDefaultCategory(type: _type);
        _categories = [category];
      }

      _accountId ??= _accounts.isNotEmpty ? _accounts.first.id : null;
      _categoryId ??= _categories.isNotEmpty ? _categories.first.id : null;

      if (_contactId != null &&
          _contacts.every((contact) => contact.id != _contactId)) {
        _contactId = null;
      }
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
          title: Text(widget.transaction == null ? 'New Transaction' : 'Edit Transaction', style: const TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: BlocConsumer<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state is TransactionOperationSuccess) {
               Navigator.pop(context, true);
            } else if (state is TransactionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is TransactionLoading;

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
                          DropdownButtonFormField<String>(
                            value: _type,
                            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 'income', child: Text('Income')),
                              DropdownMenuItem(value: 'expense', child: Text('Expense')),
                            ],
                            onChanged: (val) {
                              if (val != null && val != _type) {
                                setState(() {
                                  _type = val;
                                  _categoryId = null;
                                  _contactId = null;
                                });
                                _loadLookups();
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          BaseInput(
                            controller: _numberController,
                            label: 'Number',
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          BaseInput(
                            controller: _dateController,
                            label: 'Date',
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
                          AkauntingSelect(
                            title: 'Account',
                            isRequired: true,
                            options: _accounts
                                .map((a) => AkauntingSelectOption(
                                      key: a.id.toString(),
                                      value: a.name,
                                    ))
                                .toList(),
                            value: _accountId?.toString(),
                            onChanged: _loadingLookups
                                ? null
                                : (val) => setState(() => _accountId = int.tryParse(val ?? '')),
                          ),
                          const SizedBox(height: 16),
                          AkauntingSelect(
                            title: 'Category',
                            isRequired: true,
                            options: _categories
                                .map((c) => AkauntingSelectOption(
                                      key: c.id.toString(),
                                      value: c.name,
                                    ))
                                .toList(),
                            value: _categoryId?.toString(),
                            onChanged: _loadingLookups
                                ? null
                                : (val) => setState(() => _categoryId = int.tryParse(val ?? '')),
                          ),
                          const SizedBox(height: 16),
                          AkauntingSelect(
                            title: 'Contact (Optional)',
                            options: _contacts
                                .map((c) => AkauntingSelectOption(
                                      key: c.id.toString(),
                                      value: c.name,
                                    ))
                                .toList(),
                            value: _contactId?.toString(),
                            onChanged: _loadingLookups
                                ? null
                                : (val) => setState(() => _contactId = int.tryParse(val ?? '')),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: BaseButton(
                        child: Text(_loadingLookups ? 'Loading...' : 'Save'),
                        onPressed: (isLoading || _loadingLookups) ? null : _saveTransaction,
                        type: ButtonType.primary,
                        loading: isLoading,
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

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    if (_numberController.text.trim().isEmpty ||
        _accountId == null ||
        _categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Number, account, and category are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = {
      'type': _type,
      'number': _numberController.text.trim(),
      'paid_at': '${_dateController.text} 00:00:00',
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'currency_code': 'USD', // defaulting for now
      'currency_rate': 1,
      'description': _descriptionController.text,
      'payment_method': _paymentMethod,
      'account_id': _accountId,
      'category_id': _categoryId,
    };

    if (_contactId != null) data['contact_id'] = _contactId as Object;
    if (_referenceController.text.isNotEmpty) data['reference'] = _referenceController.text;

    if (widget.transaction == null) {
      _cubit.createTransaction(data);
    } else {
      _cubit.updateTransaction(widget.transaction!.id, data);
    }
  }
}
