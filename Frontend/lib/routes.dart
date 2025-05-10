import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_assistant/bloc/auth_bloc.dart';
import 'package:knowledge_assistant/bloc/states/auth_state.dart';
import 'package:knowledge_assistant/ui/pages/chat_page.dart';
import 'package:knowledge_assistant/ui/pages/collection_page.dart';
import 'package:knowledge_assistant/ui/pages/dashboard_page.dart';
import 'package:knowledge_assistant/ui/pages/login_page.dart';
import 'package:knowledge_assistant/ui/pages/register_page.dart';
import 'package:knowledge_assistant/ui/pages/settings_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isLoggedIn = authState is Authenticated;

      final loggingIn = state.matchedLocation == '/login';
      final registering = state.matchedLocation == '/register';

      if (!isLoggedIn && !loggingIn && !registering) return '/login';
      if (isLoggedIn && (loggingIn || registering)) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/', redirect: (_, __) => '/dashboard'),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/collection/:id',
        builder: (context, state) {
          final collectionId = state.pathParameters['id']!;
          return CollectionPage(collectionId: collectionId);
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
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
  );
}
