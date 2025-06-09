import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saviaqua/features/auth/data/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  Future<void> printSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();

  print('--- Contenido de SharedPreferences ---');
  prefs.getKeys().forEach((key) {
    print('$key: ${prefs.get(key)}');
  });
  print('--------------------------------------');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text(
                        '¿Estás seguro de que deseas cerrar sesión?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                final authService = AuthService();
                await authService.logout();
                if (context.mounted) {
                  printSharedPreferences();
                  context.go(
                    '/login',
                  ); // Asegúrate que /login exista en tus rutas
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bienvenido a SAVIAQUA'),
            ElevatedButton(
              onPressed: () {
                printSharedPreferences();
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
