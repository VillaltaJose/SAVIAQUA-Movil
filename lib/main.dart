import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saviaqua/config/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final router = await createRouter();

  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
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
