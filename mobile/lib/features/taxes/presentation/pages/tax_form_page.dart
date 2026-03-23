import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../data/models/tax_model.dart';
import '../cubit/tax_cubit.dart';
import '../cubit/tax_state.dart';

class TaxFormPage extends StatefulWidget {
  final TaxModel? tax;
  const TaxFormPage({super.key, this.tax});

  @override
  State<TaxFormPage> createState() => _TaxFormPageState();
}

class _TaxFormPageState extends State<TaxFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _rateCtrl;
  late TaxCubit _cubit;
  bool get isEditing => widget.tax != null;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<TaxCubit>();
    _nameCtrl = TextEditingController(text: widget.tax?.name ?? '');
    _rateCtrl = TextEditingController(text: widget.tax?.rate.toString() ?? '');
  }

  @override
  void dispose() { _nameCtrl.dispose(); _rateCtrl.dispose(); _cubit.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<TaxCubit, TaxState>(
        listener: (context, state) {
          if (state is TaxOperationSuccess) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message))); Navigator.pop(context); }
          else if (state is TaxError) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red)); }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(isEditing ? 'Edit Tax' : 'New Tax'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
          body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _rateCtrl, decoration: const InputDecoration(labelText: 'Rate (%)', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 24),
            BlocBuilder<TaxCubit, TaxState>(builder: (context, state) => FilledButton(
              onPressed: state is TaxLoading ? null : _submit,
              child: state is TaxLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isEditing ? 'Update' : 'Create'),
            )),
          ])),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {'name': _nameCtrl.text, 'rate': double.tryParse(_rateCtrl.text) ?? 0};
    isEditing ? _cubit.updateTax(widget.tax!.id, data) : _cubit.createTax(data);
  }
}
