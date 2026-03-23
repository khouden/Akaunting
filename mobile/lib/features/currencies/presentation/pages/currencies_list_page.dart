import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../cubit/currency_cubit.dart';
import '../cubit/currency_state.dart';
import 'currency_form_page.dart';
import 'currency_detail_page.dart';

class CurrenciesListPage extends StatefulWidget {
  const CurrenciesListPage({super.key});

  @override
  State<CurrenciesListPage> createState() => _CurrenciesListPageState();
}

class _CurrenciesListPageState extends State<CurrenciesListPage> {
  late CurrencyCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<CurrencyCubit>()..fetchCurrencies();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(title: const Text('Currencies'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
        body: BlocConsumer<CurrencyCubit, CurrencyState>(
          listener: (context, state) {
            if (state is CurrencyOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              _cubit.fetchCurrencies();
            } else if (state is CurrencyError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state is CurrencyLoading) return const Center(child: CircularProgressIndicator());
            if (state is CurrenciesLoaded) {
              if (state.currencies.isEmpty) return const Center(child: Text('No currencies found'));
              return RefreshIndicator(
                onRefresh: () => _cubit.fetchCurrencies(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.currencies.length,
                  itemBuilder: (context, index) {
                    final currency = state.currencies[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF3B82F6),
                          child: Text(currency.code.isNotEmpty ? currency.code.substring(0, currency.code.length > 2 ? 2 : currency.code.length) : '?',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        title: Text(currency.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${currency.code} • Rate: ${currency.rate} • ${currency.symbol ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(currency.enabled ? Icons.check_circle : Icons.cancel, color: currency.enabled ? Colors.green : Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'enable') _cubit.enableCurrency(currency.id);
                                if (value == 'disable') _cubit.disableCurrency(currency.id);
                                if (value == 'delete') _cubit.deleteCurrency(currency.id);
                              },
                              itemBuilder: (_) => [
                                if (!currency.enabled) const PopupMenuItem(value: 'enable', child: Text('Enable')),
                                if (currency.enabled) const PopupMenuItem(value: 'disable', child: Text('Disable')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CurrencyDetailPage(currencyId: currency.id))).then((_) => _cubit.fetchCurrencies()),
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
          heroTag: 'currencies_fab',
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencyFormPage())).then((_) => _cubit.fetchCurrencies()),
        ),
      ),
    );
  }
}
