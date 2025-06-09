import 'package:flutter/material.dart';
import 'package:saviaqua/config/router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SAVIAQUA App', 
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData.light(), 
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
    );
  }
}
