import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/events/settings_event.dart';
import 'package:knowledge_assistant/bloc/settings_bloc.dart';
import 'package:knowledge_assistant/bloc/states/settings_state.dart';
import 'package:knowledge_assistant/repositories/settings_repository.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoaded) {
            return _buildSettingsForm(context, state.settings);
          } else if (state is SettingsError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Загрузка...'));
          }
        },
      ),
    );
  }

  Widget _buildSettingsForm(BuildContext context, Settings settings) {
    StorageType selectedStorage = settings.storageType;
    ModelType selectedModel = settings.modelType;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Хранилище:', style: TextStyle(fontSize: 16)),
          DropdownButton<StorageType>(
            value: selectedStorage,
            items: StorageType.values.map((StorageType type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type == StorageType.local ? 'Локальное' : 'Серверное'),
              );
            }).toList(),
            onChanged: (StorageType? newValue) {
              if (newValue != null) {
                context.read<SettingsBloc>().add(
                  UpdateSettings(Settings(
                    storageType: newValue,
                    modelType: selectedModel,
                  )),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          const Text('Модель:', style: TextStyle(fontSize: 16)),
          DropdownButton<ModelType>(
            value: selectedModel,
            items: ModelType.values.map((ModelType type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type == ModelType.openAI ? 'OpenAI' : 'Локальная LLM'),
              );
            }).toList(),
            onChanged: (ModelType? newValue) {
              if (newValue != null) {
                context.read<SettingsBloc>().add(
                  UpdateSettings(Settings(
                    storageType: selectedStorage,
                    modelType: newValue,
                  )),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
