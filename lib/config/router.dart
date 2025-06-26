import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:saviaqua/features/auth/data/auth_notifier.dart';
import 'package:saviaqua/features/auth/presentations/login_page.dart';
import 'package:saviaqua/features/home/presentations/home_page.dart';
import 'package:saviaqua/features/home/presentations/layout/home_layout.dart';
import 'package:saviaqua/features/home/presentations/pages/add_pozo/pages/add_pozo_page.dart';
import 'package:saviaqua/features/home/presentations/pages/junta_table/pages/junta_table_view.dart';
import 'package:saviaqua/features/home/presentations/pages/junta_table/widgets/add_junta_page.dart';
import 'package:saviaqua/features/home/presentations/pages/map/pages/map_page.dart';
import 'package:saviaqua/features/home/presentations/pages/pozo_detail/pages/pozo_detail_page.dart';

GoRouter createRouter(AuthNotifier authNotifier) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.isLoggedIn;
      final goingToLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !goingToLogin) return '/login';
      if (isLoggedIn && goingToLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => HomeLayout(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(
            path: '/home/map',
            builder: (_, state) {
              final refreshKey = state.uri.queryParameters['refresh'];
              return MapPage(key: ValueKey(refreshKey));
            },
          ),
          GoRoute(
            path: '/home/pozo/:codigo',
            builder: (context, state) {
              final codigo = int.parse(state.pathParameters['codigo']!);
              return PozoDetailsPage(pozoId: codigo);
            },
          ),
          GoRoute(
            path: '/home/add-pozo',
            builder: (_, __) => const AddPozoPage(),
          ),
          GoRoute(
            path: '/home/juntas',
            builder: (_, state) {
              final refreshKey = state.uri.queryParameters['refresh'];
              return JuntaTableView(key: ValueKey(refreshKey));
            },
          ),
          GoRoute(
            path: '/home/add-junta',
            builder: (_, __) => const AddJuntaPage(),
          ),
        ],
      ),
    ],
  );
}
