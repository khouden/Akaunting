import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../cubit/setting_cubit.dart';
import '../cubit/setting_state.dart';
import 'setting_form_page.dart';

class SettingsListPage extends StatefulWidget {
  const SettingsListPage({super.key});

  @override
  State<SettingsListPage> createState() => _SettingsListPageState();
}

class _SettingsListPageState extends State<SettingsListPage> {
  late SettingCubit _cubit;

  @override
  void initState() { super.initState(); _cubit = GetIt.I<SettingCubit>()..fetchSettings(); }

  @override
  void dispose() { _cubit.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
        body: BlocConsumer<SettingCubit, SettingState>(
          listener: (context, state) {
            if (state is SettingOperationSuccess) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message))); _cubit.fetchSettings(); }
            else if (state is SettingError) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red)); }
          },
          builder: (context, state) {
            if (state is SettingLoading) return const Center(child: CircularProgressIndicator());
            if (state is SettingsLoaded) {
              if (state.settings.isEmpty) return const Center(child: Text('No settings found'));
              return RefreshIndicator(
                onRefresh: () => _cubit.fetchSettings(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.settings.length,
                  itemBuilder: (context, index) {
                    final setting = state.settings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.settings, color: Colors.blueGrey),
                        title: Text(setting.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(setting.value ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') Navigator.push(context, MaterialPageRoute(builder: (_) => SettingFormPage(setting: setting))).then((_) => _cubit.fetchSettings());
                            if (v == 'delete') _cubit.deleteSetting(setting.id);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        ),
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
          heroTag: 'settings_fab', backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingFormPage())).then((_) => _cubit.fetchSettings()),
        ),
      ),
    );
  }
}
