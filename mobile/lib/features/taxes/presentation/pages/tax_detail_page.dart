import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../cubit/tax_cubit.dart';
import '../cubit/tax_state.dart';
import 'tax_form_page.dart';

class TaxDetailPage extends StatefulWidget {
  final int taxId;
  const TaxDetailPage({super.key, required this.taxId});

  @override
  State<TaxDetailPage> createState() => _TaxDetailPageState();
}

class _TaxDetailPageState extends State<TaxDetailPage> {
  late TaxCubit _cubit;

  @override
  void initState() { super.initState(); _cubit = GetIt.I<TaxCubit>()..fetchTax(widget.taxId); }

  @override
  void dispose() { _cubit.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: const Text('Tax Details'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0,
          actions: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () { final s = _cubit.state; if (s is TaxDetailLoaded) Navigator.push(context, MaterialPageRoute(builder: (_) => TaxFormPage(tax: s.tax))).then((_) => _cubit.fetchTax(widget.taxId)); }),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
              showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Delete Tax'), content: const Text('Are you sure?'), actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(onPressed: () { Navigator.pop(context); _cubit.deleteTax(widget.taxId); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
              ]));
            }),
          ],
        ),
        body: BlocConsumer<TaxCubit, TaxState>(
          listener: (context, state) { if (state is TaxOperationSuccess) Navigator.pop(context); },
          builder: (context, state) {
            if (state is TaxLoading) return const Center(child: CircularProgressIndicator());
            if (state is TaxDetailLoaded) {
              final t = state.tax;
              return ListView(padding: const EdgeInsets.all(16), children: [
                _Row('Name', t.name), _Row('Rate', '${t.rate}%'), _Row('Status', t.enabled ? 'Enabled' : 'Disabled'),
                if (t.createdAt != null) _Row('Created', t.createdAt!),
              ]);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
    SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
    Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
  ]));
}
