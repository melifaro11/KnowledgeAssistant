import 'package:knowledge_assistant/repositories/settings_repository.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final Settings settings;

  const SettingsLoaded(this.settings);
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);
}
