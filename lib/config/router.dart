import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saviaqua/features/auth/presentations/login_page.dart';
import 'package:saviaqua/features/home/presentations/home_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
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
);
