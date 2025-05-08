import 'package:shared_preferences/shared_preferences.dart';

enum StorageType { local, server }
enum ModelType { openAI, localLLM }

class Settings {
  final StorageType storageType;
  final ModelType modelType;

  Settings({
    required this.storageType,
    required this.modelType,
  });
}

class SettingsRepository {
  static const String _storageTypeKey = 'storageType';
  static const String _modelTypeKey = 'modelType';

  Future<Settings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final storageIndex = prefs.getInt(_storageTypeKey) ?? 0;
    final modelIndex = prefs.getInt(_modelTypeKey) ?? 0;

    final storageType = StorageType.values[storageIndex];
    final modelType = ModelType.values[modelIndex];

    return Settings(
      storageType: storageType,
      modelType: modelType,
    );
  }

  Future<void> saveSettings(Settings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_storageTypeKey, settings.storageType.index);
    await prefs.setInt(_modelTypeKey, settings.modelType.index);
  }
}
