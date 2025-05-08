import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/events/settings_event.dart';
import 'package:knowledge_assistant/bloc/states/settings_state.dart';
import '../../repositories/settings_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc({required this.repository}) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
  }

  Future<void> _onLoadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final settings = await repository.loadSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Не удалось загрузить настройки'));
    }
  }

  Future<void> _onUpdateSettings(
      UpdateSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      await repository.saveSettings(event.settings);
      emit(SettingsLoaded(event.settings));
    } catch (e) {
      emit(SettingsError('Не удалось сохранить настройки'));
    }
  }
}
