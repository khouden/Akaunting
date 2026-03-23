import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../cubit/currency_cubit.dart';
import '../cubit/currency_state.dart';
import 'currency_form_page.dart';

class CurrencyDetailPage extends StatefulWidget {
  final int currencyId;
  const CurrencyDetailPage({super.key, required this.currencyId});

  @override
  State<CurrencyDetailPage> createState() => _CurrencyDetailPageState();
}

class _CurrencyDetailPageState extends State<CurrencyDetailPage> {
  late CurrencyCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<CurrencyCubit>()..fetchCurrency(widget.currencyId);
  }

  @override
  void dispose() { _cubit.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Currency Details'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0,
          actions: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () {
              final state = _cubit.state;
              if (state is CurrencyDetailLoaded) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CurrencyFormPage(currency: state.currency))).then((_) => _cubit.fetchCurrency(widget.currencyId));
              }
            }),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
              showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Delete Currency'), content: const Text('Are you sure?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(onPressed: () { Navigator.pop(context); _cubit.deleteCurrency(widget.currencyId); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
                ],
              ));
            }),
          ],
        ),
        body: BlocConsumer<CurrencyCubit, CurrencyState>(
          listener: (context, state) { if (state is CurrencyOperationSuccess) Navigator.pop(context); },
          builder: (context, state) {
            if (state is CurrencyLoading) return const Center(child: CircularProgressIndicator());
            if (state is CurrencyDetailLoaded) {
              final c = state.currency;
              return ListView(padding: const EdgeInsets.all(16), children: [
                _Row('Name', c.name), _Row('Code', c.code), _Row('Rate', c.rate.toString()),
                _Row('Symbol', c.symbol ?? '-'), _Row('Precision', c.precision?.toString() ?? '-'),
                _Row('Status', c.enabled ? 'Enabled' : 'Disabled'),
                if (c.createdAt != null) _Row('Created', c.createdAt!),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
    ]),
  );
}
