import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/dashboard_model.dart';
import '../../../../core/ui/components/inputs/base_input.dart';
import '../../../../core/ui/components/akaunting_switch.dart';
import '../../../../core/ui/components/base_button.dart';
import '../../../../core/ui/components/cards/card.dart';
import '../../../../logic/cubits/dashboard_cubit.dart';
import '../../../../core/di/injection_container.dart';

class DashboardFormPage extends StatelessWidget {
  final DashboardModel? dashboard;

  const DashboardFormPage({super.key, this.dashboard});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (context) => sl<DashboardCubit>(),
      child: _DashboardFormView(dashboard: dashboard),
    );
  }
}

class _DashboardFormView extends StatefulWidget {
  final DashboardModel? dashboard;

  const _DashboardFormView({this.dashboard});

  @override
  State<_DashboardFormView> createState() => _DashboardFormViewState();
}

class _DashboardFormViewState extends State<_DashboardFormView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    final dash = widget.dashboard;
    _nameController = TextEditingController(text: dash?.name ?? '');
    _enabled = dash?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields'), backgroundColor: Colors.red),
      );
      return;
    }

    final data = {
      'name': _nameController.text.trim(),
      'enabled': _enabled ? 1 : 0,
    };

    if (widget.dashboard == null) {
      context.read<DashboardCubit>().createDashboard(data);
    } else {
      context.read<DashboardCubit>().updateDashboard(widget.dashboard!.id, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(widget.dashboard == null ? 'New Dashboard' : 'Edit Dashboard',
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {
          if (state is DashboardSaved) {
            Navigator.of(context).pop(state.dashboard);
          } else if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is DashboardLoading;

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
                        BaseInput(
                          label: 'Name',
                          isRequired: true,
                          controller: _nameController,
                          placeholder: 'Main Dashboard',
                        ),
                        if (widget.dashboard != null) ...[
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
