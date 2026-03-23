import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../data/models/currency_model.dart';
import '../cubit/currency_cubit.dart';
import '../cubit/currency_state.dart';

class CurrencyFormPage extends StatefulWidget {
  final CurrencyModel? currency;
  const CurrencyFormPage({super.key, this.currency});

  @override
  State<CurrencyFormPage> createState() => _CurrencyFormPageState();
}

class _CurrencyFormPageState extends State<CurrencyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _codeCtrl, _rateCtrl, _symbolCtrl, _precisionCtrl, _decimalCtrl, _thousandsCtrl;
  int _symbolFirst = 1;
  late CurrencyCubit _cubit;
  bool get isEditing => widget.currency != null;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<CurrencyCubit>();
    final c = widget.currency;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _codeCtrl = TextEditingController(text: c?.code ?? '');
    _rateCtrl = TextEditingController(text: c?.rate.toString() ?? '1.0');
    _symbolCtrl = TextEditingController(text: c?.symbol ?? '');
    _precisionCtrl = TextEditingController(text: c?.precision?.toString() ?? '2');
    _decimalCtrl = TextEditingController(text: c?.decimalMark ?? '.');
    _thousandsCtrl = TextEditingController(text: c?.thousandsSeparator ?? ',');
    _symbolFirst = c?.symbolFirst ?? 1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _codeCtrl.dispose(); _rateCtrl.dispose(); _symbolCtrl.dispose();
    _precisionCtrl.dispose(); _decimalCtrl.dispose(); _thousandsCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<CurrencyCubit, CurrencyState>(
        listener: (context, state) {
          if (state is CurrencyOperationSuccess) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message))); Navigator.pop(context); }
          else if (state is CurrencyError) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red)); }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(isEditing ? 'Edit Currency' : 'New Currency'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
          body: Form(
            key: _formKey,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _codeCtrl, decoration: const InputDecoration(labelText: 'Code (e.g., USD)', border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _rateCtrl, decoration: const InputDecoration(labelText: 'Rate', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextFormField(controller: _symbolCtrl, decoration: const InputDecoration(labelText: 'Symbol', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(controller: _precisionCtrl, decoration: const InputDecoration(labelText: 'Precision', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _symbolFirst,
                decoration: const InputDecoration(labelText: 'Symbol Position', border: OutlineInputBorder()),
                items: const [DropdownMenuItem(value: 1, child: Text('Before Amount')), DropdownMenuItem(value: 0, child: Text('After Amount'))],
                onChanged: (v) => setState(() => _symbolFirst = v ?? 1),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TextFormField(controller: _decimalCtrl, decoration: const InputDecoration(labelText: 'Decimal Mark', border: OutlineInputBorder()))),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _thousandsCtrl, decoration: const InputDecoration(labelText: 'Thousands Sep', border: OutlineInputBorder()))),
              ]),
              const SizedBox(height: 24),
              BlocBuilder<CurrencyCubit, CurrencyState>(
                builder: (context, state) => FilledButton(
                  onPressed: state is CurrencyLoading ? null : _submit,
                  child: state is CurrencyLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isEditing ? 'Update' : 'Create'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _nameCtrl.text, 'code': _codeCtrl.text,
      'rate': double.tryParse(_rateCtrl.text) ?? 1.0, 'symbol': _symbolCtrl.text,
      'precision': int.tryParse(_precisionCtrl.text) ?? 2, 'symbol_first': _symbolFirst,
      'decimal_mark': _decimalCtrl.text, 'thousands_separator': _thousandsCtrl.text,
    };
    isEditing ? _cubit.updateCurrency(widget.currency!.id, data) : _cubit.createCurrency(data);
  }
}
