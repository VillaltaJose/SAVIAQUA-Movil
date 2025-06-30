import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saviaqua/features/auth/data/auth_notifier.dart';
import 'package:saviaqua/features/auth/presentations/forgot_password/forgot_password_page.dart';
import 'package:saviaqua/features/auth/presentations/login/login_page.dart';
import 'package:saviaqua/features/home/presentations/home_page.dart';
import 'package:saviaqua/features/home/presentations/layout/home_layout.dart';
import 'package:saviaqua/features/home/presentations/pages/add_pozo/pages/add_pozo_page.dart';
import 'package:saviaqua/features/home/presentations/pages/junta_table/pages/junta_table_view.dart';
import 'package:saviaqua/features/home/presentations/pages/junta_table/widgets/add_junta_page.dart';
import 'package:saviaqua/features/home/presentations/pages/map/pages/map_page.dart';
import 'package:saviaqua/features/home/presentations/pages/pozo_detail/pages/pozo_detail_page.dart';
import 'package:saviaqua/features/home/presentations/pages/user-management/pages/user_profile_page.dart';
import 'package:saviaqua/features/home/presentations/pages/user-management/pages/user_table_view.dart';
import 'package:saviaqua/features/home/presentations/pages/user-management/widgets/add_user_page.dart';
import 'package:saviaqua/features/home/presentations/pages/user-management/widgets/edit_user_page.dart';

GoRouter createRouter(AuthNotifier authNotifier) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.isLoggedIn;
      final goingToLogin = state.matchedLocation == '/login';
      final goingToForgotPassword = state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !goingToLogin && !goingToForgotPassword) {
        return '/login';
      }
      if (isLoggedIn && goingToLogin) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),

      // GoRoute(
      //   path: '/verify-code',
      //   builder: (context, state) {
      //     final email = state.uri.queryParameters['email']!;
      //     return VerifyCodePage(email: email);
      //   },
      // ),
      // GoRoute(
      //   path: '/reset-password',
      //   builder: (context, state) {
      //     final email = state.uri.queryParameters['email']!;
      //     return ResetPasswordPage(email: email);
      //   },
      // ),
      ShellRoute(
        builder: (context, state, child) => HomeLayout(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(
            path: '/home/edit-user',
            builder: (_, __) => const EditUserPage(userId: 0),
          ),
          GoRoute(
            path: '/home/edit-profile',
            builder: (_, __) => const UserProfilePage(),
          ),

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
          GoRoute(
            path: '/home/users',
            builder: (_, state) {
              final refreshKey = state.uri.queryParameters['refresh'];
              return UserTableView(key: ValueKey(refreshKey));
            },
          ),
          GoRoute(
            path: '/home/add-user',
            builder: (_, __) => const AddUserPage(),
          ),
          GoRoute(
            path: '/home/user/:id',
            builder: (_, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                return const Scaffold(body: Center(child: Text('ID inválido')));
              }
              return EditUserPage(userId: id);
            },
          ),
        ],
      ),
    ],
  );
}
