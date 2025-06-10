import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saviaqua/features/auth/data/auth_notifier.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void printSecureStorageContent() async {
    const storage = FlutterSecureStorage();
    final allValues = await storage.readAll();

    print('--- Contenido de Secure Storage ---');
    allValues.forEach((key, value) {
      print('$key: $value');
    });
    print('-----------------------------------');
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.read<AuthNotifier>();

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
                await authNotifier.logout();
                if (context.mounted) {
                  printSecureStorageContent();
                  context.go('/login');
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
                printSecureStorageContent(); 
              },
              child: const Text('Ver Storage Seguro'),
            ),
          ],
        ),
      ),
    );
  }
}
