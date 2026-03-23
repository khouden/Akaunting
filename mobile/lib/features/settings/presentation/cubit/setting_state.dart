import '../../../../data/models/setting_model.dart';

abstract class SettingState {
  const SettingState();
}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {}

class SettingsLoaded extends SettingState {
  final List<SettingModel> settings;
  const SettingsLoaded(this.settings);
}

class SettingDetailLoaded extends SettingState {
  final SettingModel setting;
  const SettingDetailLoaded(this.setting);
}

class SettingError extends SettingState {
  final String message;
  const SettingError(this.message);
}

class SettingOperationSuccess extends SettingState {
  final String message;
  const SettingOperationSuccess(this.message);
}
