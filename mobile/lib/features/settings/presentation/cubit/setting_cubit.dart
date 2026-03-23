import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/repositories/setting_repository.dart';
import 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  final SettingRepository _repository = GetIt.I<SettingRepository>();

  SettingCubit() : super(SettingInitial());

  Future<void> fetchSettings() async {
    emit(SettingLoading());
    try {
      final settings = await _repository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingError(e.toString()));
    }
  }

  Future<void> fetchSetting(dynamic id) async {
    emit(SettingLoading());
    try {
      final setting = await _repository.getSetting(id);
      emit(SettingDetailLoaded(setting));
    } catch (e) {
      emit(SettingError(e.toString()));
    }
  }

  Future<void> createSetting(Map<String, dynamic> data) async {
    emit(SettingLoading());
    try {
      await _repository.createSetting(data);
      emit(const SettingOperationSuccess('Setting created successfully'));
    } catch (e) {
      emit(SettingError(e.toString()));
    }
  }

  Future<void> updateSetting(int id, Map<String, dynamic> data) async {
    emit(SettingLoading());
    try {
      await _repository.updateSetting(id, data);
      emit(const SettingOperationSuccess('Setting updated successfully'));
    } catch (e) {
      emit(SettingError(e.toString()));
    }
  }

  Future<void> deleteSetting(int id) async {
    emit(SettingLoading());
    try {
      await _repository.deleteSetting(id);
      emit(const SettingOperationSuccess('Setting deleted successfully'));
    } catch (e) {
      emit(SettingError(e.toString()));
    }
  }
}
