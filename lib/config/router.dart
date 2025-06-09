import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saviaqua/features/auth/presentations/login_page.dart';
import 'package:saviaqua/features/home/presentations/home_page.dart';

Future<GoRouter> createRouter() async {
  final prefs = await SharedPreferences.getInstance();
  final hasSession = prefs.containsKey('session_token');

  return GoRouter(
    initialLocation: hasSession ? '/home' : '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomePage(),
      ),
    ],
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.containsKey('session_token');

      final loggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !loggingIn) return '/login';
      if (isLoggedIn && loggingIn) return '/home';

      return null;
    },
  );
}
