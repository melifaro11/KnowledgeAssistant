import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowledge_assistant/bloc/auth_bloc.dart';
import 'package:knowledge_assistant/bloc/chat_bloc.dart';
import 'package:knowledge_assistant/bloc/collections_bloc.dart';
import 'package:knowledge_assistant/bloc/events/collections_event.dart';
import 'package:knowledge_assistant/bloc/events/settings_event.dart';
import 'package:knowledge_assistant/bloc/settings_bloc.dart';
import 'package:knowledge_assistant/repositories/auth_repository.dart';
import 'package:knowledge_assistant/repositories/chat_repository.dart';
import 'package:knowledge_assistant/repositories/collections_repository.dart';
import 'package:knowledge_assistant/repositories/settings_repository.dart';
import 'package:knowledge_assistant/routes.dart';
import 'package:knowledge_assistant/theme.dart';

final baseUri = "http://127.0.0.1:8000";

final lightTheme = ThemeData.light(useMaterial3: true);

final darkTheme = ThemeData.dark(useMaterial3: true);

void main() {
  runApp(KnowledgeAssistantApp());
}

class KnowledgeAssistantApp extends StatelessWidget {
  final AuthRepository authRepository = AuthRepository(baseUrl: baseUri);
  final ChatRepository chatRepository = ChatRepository(baseUrl: baseUri);
  final CollectionsRepository collectionsRepository = CollectionsRepository(
    baseUrl: baseUri,
  );
  final SettingsRepository settingsRepository = SettingsRepository();

  KnowledgeAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: chatRepository),
        RepositoryProvider.value(value: collectionsRepository),
        RepositoryProvider.value(value: settingsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(authRepository: authRepository),
          ),
          BlocProvider(
            create: (context) => ChatBloc(repository: chatRepository),
          ),
          BlocProvider(
            create:
                (context) =>
                    CollectionsBloc(repository: collectionsRepository)
                      ..add(LoadCollections()),
          ),
          BlocProvider(
            create:
                (context) =>
                    SettingsBloc(repository: settingsRepository)
                      ..add(LoadSettings()),
          ),
        ],
        child: MaterialApp.router(
          title: 'AI Knowledge Assistant',
          //theme: lightTheme,
          theme: knowledgeAITheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
