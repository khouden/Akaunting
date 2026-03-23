import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../cubit/tax_cubit.dart';
import '../cubit/tax_state.dart';
import 'tax_form_page.dart';
import 'tax_detail_page.dart';

class TaxesListPage extends StatefulWidget {
  const TaxesListPage({super.key});

  @override
  State<TaxesListPage> createState() => _TaxesListPageState();
}

class _TaxesListPageState extends State<TaxesListPage> {
  late TaxCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<TaxCubit>()..fetchTaxes();
  }

  @override
  void dispose() { _cubit.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(title: const Text('Taxes'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
        body: BlocConsumer<TaxCubit, TaxState>(
          listener: (context, state) {
            if (state is TaxOperationSuccess) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message))); _cubit.fetchTaxes(); }
            else if (state is TaxError) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red)); }
          },
          builder: (context, state) {
            if (state is TaxLoading) return const Center(child: CircularProgressIndicator());
            if (state is TaxesLoaded) {
              if (state.taxes.isEmpty) return const Center(child: Text('No taxes found'));
              return RefreshIndicator(
                onRefresh: () => _cubit.fetchTaxes(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.taxes.length,
                  itemBuilder: (context, index) {
                    final tax = state.taxes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: const Color(0xFFF59E0B), child: const Icon(Icons.percent, color: Colors.white, size: 20)),
                        title: Text(tax.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Rate: ${tax.rate}%'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(tax.enabled ? Icons.check_circle : Icons.cancel, color: tax.enabled ? Colors.green : Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: (v) { if (v == 'enable') _cubit.enableTax(tax.id); if (v == 'disable') _cubit.disableTax(tax.id); if (v == 'delete') _cubit.deleteTax(tax.id); },
                            itemBuilder: (_) => [
                              if (!tax.enabled) const PopupMenuItem(value: 'enable', child: Text('Enable')),
                              if (tax.enabled) const PopupMenuItem(value: 'disable', child: Text('Disable')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ]),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaxDetailPage(taxId: tax.id))).then((_) => _cubit.fetchTaxes()),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'taxes_fab', backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxFormPage())).then((_) => _cubit.fetchTaxes()),
        ),
      ),
    );
  }
}
