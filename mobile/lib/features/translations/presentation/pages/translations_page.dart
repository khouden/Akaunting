import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../cubit/translation_cubit.dart';
import '../cubit/translation_state.dart';

class TranslationsPage extends StatefulWidget {
  const TranslationsPage({super.key});

  @override
  State<TranslationsPage> createState() => _TranslationsPageState();
}

class _TranslationsPageState extends State<TranslationsPage> {
  late TranslationCubit _cubit;
  String _locale = 'en-GB';

  final _locales = ['en-GB', 'fr-FR', 'es-ES', 'de-DE', 'ar-SA', 'pt-BR', 'zh-CN'];

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<TranslationCubit>()..fetchAll(_locale);
  }

  @override
  void dispose() { _cubit.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(title: const Text('Translations'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                value: _locale,
                decoration: const InputDecoration(labelText: 'Locale', border: OutlineInputBorder()),
                items: _locales.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _locale = v);
                    _cubit.fetchAll(v);
                  }
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<TranslationCubit, TranslationState>(
                builder: (context, state) {
                  if (state is TranslationLoading) return const Center(child: CircularProgressIndicator());
                  if (state is TranslationError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                  if (state is TranslationsLoaded) {
                    final entries = <MapEntry<String, String>>[];
                    _flattenMap(state.translations, '', entries);
                    if (entries.isEmpty) return const Center(child: Text('No translations found'));
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: ListTile(
                            dense: true,
                            title: Text(entry.key, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                            subtitle: Text(entry.value, style: const TextStyle(fontSize: 14)),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _flattenMap(Map<String, dynamic> map, String prefix, List<MapEntry<String, String>> result) {
    map.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        _flattenMap(value, fullKey, result);
      } else {
        result.add(MapEntry(fullKey, value.toString()));
      }
    });
  }
}
