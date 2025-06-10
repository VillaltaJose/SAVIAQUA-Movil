import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saviaqua/config/router.dart';
import 'package:saviaqua/features/auth/data/auth_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);
    final router = createRouter(authNotifier);

    return MaterialApp.router(
      routerConfig: router,
      title: 'SAVIAQUA App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
    );
  }
}
