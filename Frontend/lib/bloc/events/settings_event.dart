import 'package:knowledge_assistant/repositories/settings_repository.dart';

abstract class SettingsEvent {
  const SettingsEvent();
}

class LoadSettings extends SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final Settings settings;

  const UpdateSettings(this.settings);
}
