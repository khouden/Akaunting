import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../data/models/setting_model.dart';
import '../cubit/setting_cubit.dart';
import '../cubit/setting_state.dart';

class SettingFormPage extends StatefulWidget {
  final SettingModel? setting;
  const SettingFormPage({super.key, this.setting});

  @override
  State<SettingFormPage> createState() => _SettingFormPageState();
}

class _SettingFormPageState extends State<SettingFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _keyCtrl, _valueCtrl;
  late SettingCubit _cubit;
  bool get isEditing => widget.setting != null;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<SettingCubit>();
    _keyCtrl = TextEditingController(text: widget.setting?.key ?? '');
    _valueCtrl = TextEditingController(text: widget.setting?.value ?? '');
  }

  @override
  void dispose() { _keyCtrl.dispose(); _valueCtrl.dispose(); _cubit.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SettingCubit, SettingState>(
        listener: (context, state) {
          if (state is SettingOperationSuccess) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message))); Navigator.pop(context); }
          else if (state is SettingError) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red)); }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(isEditing ? 'Edit Setting' : 'New Setting'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
          body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
            TextFormField(controller: _keyCtrl, decoration: const InputDecoration(labelText: 'Key', border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Required' : null, enabled: !isEditing),
            const SizedBox(height: 16),
            TextFormField(controller: _valueCtrl, decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 24),
            BlocBuilder<SettingCubit, SettingState>(builder: (context, state) => FilledButton(
              onPressed: state is SettingLoading ? null : _submit,
              child: state is SettingLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isEditing ? 'Update' : 'Create'),
            )),
          ])),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {'key': _keyCtrl.text, 'value': _valueCtrl.text};
    isEditing ? _cubit.updateSetting(widget.setting!.id, data) : _cubit.createSetting(data);
  }
}
