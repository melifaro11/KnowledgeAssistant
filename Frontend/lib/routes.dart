import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_assistant/bloc/auth_bloc.dart';
import 'package:knowledge_assistant/bloc/states/auth_state.dart';
import 'package:knowledge_assistant/ui/screens/chat_screen.dart';
import 'package:knowledge_assistant/ui/screens/collection_screen.dart';
import 'package:knowledge_assistant/ui/screens/dashboard_screen.dart';
import 'package:knowledge_assistant/ui/screens/login_screen.dart';
import 'package:knowledge_assistant/ui/screens/settings_screen.dart';


class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isLoggedIn = authState is Authenticated;

      final loggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !loggingIn) return '/login';
      if (isLoggedIn && loggingIn) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/collection/:id',
        builder: (context, state) {
          final collectionId = state.pathParameters['id']!;
          return CollectionsPage();
        },
      ),
      GoRoute(
        path: '/chat/:collectionId',
        builder: (context, state) {
          final collectionId = state.pathParameters['collectionId']!;
          return ChatPage(collectionId: collectionId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
