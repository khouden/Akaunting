import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/ui/components/base_button.dart';
import '../../../../core/ui/components/inputs/base_input.dart';
import '../../../../core/ui/components/akaunting_select.dart';
import '../../../../core/ui/components/base_alert.dart';
import '../../../../data/models/reconciliation_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/account_model.dart';
import '../../../../logic/cubits/reconciliation_cubit.dart';
import '../../../../logic/cubits/account_cubit.dart';

class ReconciliationFormPage extends StatelessWidget {
  final ReconciliationModel? reconciliation;

  const ReconciliationFormPage({super.key, this.reconciliation});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ReconciliationCubit>(
          create: (context) => sl<ReconciliationCubit>(),
        ),
        BlocProvider<AccountCubit>(
          create: (context) => sl<AccountCubit>()..loadAccounts(),
        ),
      ],
      child: ReconciliationFormView(reconciliation: reconciliation),
    );
  }
}

class ReconciliationFormView extends StatefulWidget {
  final ReconciliationModel? reconciliation;

  const ReconciliationFormView({super.key, this.reconciliation});

  @override
  State<ReconciliationFormView> createState() => _ReconciliationFormViewState();
}

class _ReconciliationFormViewState extends State<ReconciliationFormView> {
  final _formKey = GlobalKey<FormState>();
  final _closingBalanceController = TextEditingController();
  
  int? _accountId;
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _reconciled = false;
  
  List<TransactionModel> _transactions = [];
  final Set<int> _selectedTransactions = {};

  @override
  void initState() {
    super.initState();
    if (widget.reconciliation != null) {
      _accountId = widget.reconciliation!.accountId;
      _startedAt = DateTime.tryParse(widget.reconciliation!.startedAt);
      _endedAt = DateTime.tryParse(widget.reconciliation!.endedAt);
      _closingBalanceController.text = widget.reconciliation!.closingBalance.toString();
      _reconciled = widget.reconciliation!.reconciled;
    } else {
      _startedAt = DateTime.now();
      _endedAt = DateTime.now().add(const Duration(days: 30));
      _closingBalanceController.text = '0.00';
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTransactions();
    });
  }

  void _fetchTransactions() {
    if (_accountId != null && _startedAt != null && _endedAt != null) {
      context.read<ReconciliationCubit>().loadTransactions(
        _accountId!, 
        '${_startedAt!.toIso8601String().split('T').first} 00:00:00',
        '${_endedAt!.toIso8601String().split('T').first} 23:59:59'
      );
    }
  }

  @override
  void dispose() {
    _closingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startedAt : _endedAt) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startedAt = picked;
        } else {
          _endedAt = picked;
        }
      });
      _fetchTransactions();
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      if (_accountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an account')),
        );
        return;
      }
      if (_startedAt == null || _endedAt == null) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end dates')),
        );
        return;
      }

      final tempTransactions = <String, dynamic>{};
      for (var tx in _transactions) {
        tempTransactions['${tx.type}_${tx.id}'] = _selectedTransactions.contains(tx.id) ? 'true' : 'false';
      }

      final data = {
        'account_id': _accountId,
        'started_at': '${_startedAt!.toIso8601String().split('T').first} 00:00:00',
        'ended_at': '${_endedAt!.toIso8601String().split('T').first} 23:59:59',
        'closing_balance': double.tryParse(_closingBalanceController.text) ?? 0.0,
        'reconcile': _reconciled ? 1 : 0,
        'transactions': tempTransactions,
      };

      if (widget.reconciliation == null) {
        context.read<ReconciliationCubit>().createReconciliation(data);
      } else {
        context.read<ReconciliationCubit>().updateReconciliation(widget.reconciliation!.id, data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reconciliation == null ? 'New Reconciliation' : 'Edit Reconciliation', 
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: BlocConsumer<ReconciliationCubit, ReconciliationState>(
        listener: (context, state) {
          if (state is ReconciliationSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reconciliation saved successfully')),
            );
            Navigator.of(context).pop(true);
          } else if (state is ReconciliationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is ReconciliationTransactionsLoaded) {
            setState(() {
              _transactions = state.transactions;
            });
          }
        },
        builder: (context, state) {
          final isSaving = state is ReconciliationLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const SizedBox(height: 8),

                // Account Selection
                BlocBuilder<AccountCubit, AccountState>(
                  builder: (context, accState) {
                    if (accState is AccountLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (accState is AccountsLoaded) {
                      return AkauntingSelect(
                        title: 'Account',
                        value: _accountId?.toString(),
                        options: accState.accounts.map((acc) => AkauntingSelectOption(value: acc.name, key: acc.id.toString())).toList(),
                        onChanged: (val) {
                          setState(() {
                            _accountId = val != null ? int.tryParse(val) : null;
                          });
                          _fetchTransactions();
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                const SizedBox(height: 16),

                // Started At
                InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Started At',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_startedAt?.toIso8601String().split('T').first ?? 'Select Date'),
                  ),
                ),
                const SizedBox(height: 16),

                // Ended At
                InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ended At',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_endedAt?.toIso8601String().split('T').first ?? 'Select Date'),
                  ),
                ),
                const SizedBox(height: 16),

                // Closing Balance
                BaseInput(
                  label: 'Closing Balance',
                  controller: _closingBalanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                
                SwitchListTile(
                  title: const Text('Reconciled', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: _reconciled,
                  onChanged: (bool value) {
                    setState(() {
                      _reconciled = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),

                if (_transactions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        final isSelected = _selectedTransactions.contains(tx.id);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (bool? val) {
                            setState(() {
                              if (val == true) {
                                _selectedTransactions.add(tx.id);
                              } else {
                                _selectedTransactions.remove(tx.id);
                              }
                            });
                          },
                          title: Text(tx.amountFormatted ?? '\$${tx.amount.toStringAsFixed(2)}', 
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${tx.paidAt.split('T').first} - ${tx.description ?? tx.type}'),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                ] else if (_accountId != null) ...[
                  const SizedBox(height: 16),
                  const Text('No transactions found for the selected period.', 
                             style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ],

                const SizedBox(height: 32),
                
                BaseButton(
                  onPressed: isSaving ? null : _submit,
                  type: ButtonType.primary,
                  block: true,
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
