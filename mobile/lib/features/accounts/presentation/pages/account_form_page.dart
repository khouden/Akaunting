import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/account_model.dart';
import '../../../../core/ui/components/inputs/base_input.dart';
import '../../../../core/ui/components/akaunting_money.dart';
import '../../../../core/ui/components/akaunting_radio_group.dart';
import '../../../../core/ui/components/akaunting_select.dart';
import '../../../../core/ui/components/akaunting_switch.dart';
import '../../../../core/ui/components/base_button.dart';
import '../../../../core/ui/components/cards/card.dart';
import '../../../../logic/cubits/account_cubit.dart';
import '../../../../core/di/injection_container.dart';

class AccountFormPage extends StatelessWidget {
  final AccountModel? account;

  const AccountFormPage({super.key, this.account});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountCubit>(
      create: (context) => sl<AccountCubit>(),
      child: _AccountFormView(account: account),
    );
  }
}

class _AccountFormView extends StatefulWidget {
  final AccountModel? account;

  const _AccountFormView({this.account});

  @override
  State<_AccountFormView> createState() => _AccountFormViewState();
}

class _AccountFormViewState extends State<_AccountFormView> {
  final _formKey = GlobalKey<FormState>();
  
  late int _type; // 1 = bank, 0 = credit_card (mapping for UI radio group)
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late String _currencyCode;
  String? _openingBalance;
  late bool _enabled;
  bool _defaultAccount = false;
  late TextEditingController _bankNameController;
  late TextEditingController _bankPhoneController;
  late TextEditingController _bankAddressController;

  @override
  void initState() {
    super.initState();
    final acc = widget.account;
    _type = acc?.type == 'credit_card' ? 0 : 1;
    _nameController = TextEditingController(text: acc?.name ?? '');
    _numberController = TextEditingController(text: acc?.number ?? '');
    _currencyCode = acc?.currencyCode ?? 'USD'; // In real app, fetch default from settings
    _openingBalance = acc?.openingBalance.toString() ?? '0.00';
    _enabled = acc?.enabled ?? true;
    _bankNameController = TextEditingController(text: acc?.bankName ?? '');
    _bankPhoneController = TextEditingController(text: acc?.bankPhone ?? '');
    _bankAddressController = TextEditingController(text: acc?.bankAddress ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _bankNameController.dispose();
    _bankPhoneController.dispose();
    _bankAddressController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_nameController.text.trim().isEmpty || _numberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields'), backgroundColor: Colors.red),
      );
      return;
    }

    final data = {
      'type': _type == 1 ? 'bank' : 'credit_card',
      'name': _nameController.text.trim(),
      'number': _numberController.text.trim(),
      'currency_code': _currencyCode,
      'opening_balance': _openingBalance,
      'enabled': _enabled ? 1 : 0,
      'default_account': _defaultAccount ? 1 : 0,
    };

    if (_bankNameController.text.isNotEmpty) data['bank_name'] = _bankNameController.text.trim();
    if (_bankPhoneController.text.isNotEmpty) data['bank_phone'] = _bankPhoneController.text.trim();
    if (_bankAddressController.text.isNotEmpty) data['bank_address'] = _bankAddressController.text.trim();

    if (widget.account == null) {
      context.read<AccountCubit>().createAccount(data);
    } else {
      context.read<AccountCubit>().updateAccount(widget.account!.id, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(widget.account == null ? 'New Account' : 'Edit Account',
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: BlocConsumer<AccountCubit, AccountState>(
        listener: (context, state) {
          if (state is AccountSaved) {
            Navigator.of(context).pop(state.account);
          } else if (state is AccountError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AccountLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text('General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  AppCard(
                    child: Column(
                      children: [
                        AkauntingRadioGroup(
                          text: 'Type',
                          value: _type,
                          enableText: 'Bank',
                          disableText: 'Credit Card',
                          onChanged: (val) => setState(() => _type = val),
                        ),
                        const SizedBox(height: 16),
                        BaseInput(
                          label: 'Name',
                          isRequired: true,
                          controller: _nameController,
                          placeholder: 'Cash',
                        ),
                        const SizedBox(height: 16),
                        BaseInput(
                          label: 'Number',
                          isRequired: true,
                          controller: _numberController,
                          placeholder: '1001',
                        ),
                        const SizedBox(height: 16),
                        AkauntingSelect(
                          title: 'Currency',
                          isRequired: true,
                          value: _currencyCode,
                          options: [
                            AkauntingSelectOption(key: 'USD', value: 'US Dollar'),
                            AkauntingSelectOption(key: 'EUR', value: 'Euro'),
                            AkauntingSelectOption(key: 'GBP', value: 'British Pound'),
                            // More currencies could be loaded dynamically in real scenario
                          ],
                          onChanged: (val) => setState(() => _currencyCode = val!),
                        ),
                        const SizedBox(height: 16),
                        AkauntingMoney(
                          title: 'Opening Balance',
                          isRequired: true,
                          value: _openingBalance,
                          onChanged: (val) => _openingBalance = val,
                        ),
                        if (_type == 1) ...[
                          const SizedBox(height: 16),
                          AkauntingSwitch(
                            label: 'Default Account',
                            value: _defaultAccount,
                            onChanged: (val) => setState(() => _defaultAccount = val),
                          )
                        ],
                        if (widget.account != null) ...[
                          const SizedBox(height: 16),
                          AkauntingSwitch(
                            label: 'Enabled',
                            value: _enabled,
                            onChanged: (val) => setState(() => _enabled = val),
                          )
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text('Bank Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  AppCard(
                    child: Column(
                      children: [
                        BaseInput(
                          label: 'Bank Name',
                          controller: _bankNameController,
                          placeholder: 'Bank Name',
                        ),
                        const SizedBox(height: 16),
                        BaseInput(
                          label: 'Bank Phone',
                          controller: _bankPhoneController,
                          placeholder: 'Bank Phone',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        BaseInput(
                          label: 'Bank Address',
                          controller: _bankAddressController,
                          placeholder: 'Bank Address',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: BaseButton(
                          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                          type: ButtonType.defaultType,
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: BaseButton(
                          onPressed: isLoading ? null : _onSubmit,
                          type: ButtonType.primary,
                          loading: isLoading,
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
