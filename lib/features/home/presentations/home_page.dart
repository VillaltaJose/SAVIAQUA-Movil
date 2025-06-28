import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:saviaqua/features/auth/data/auth_notifier.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? userName;
  String? userEmail;
  int? codigoUsuario;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<Map<String, dynamic>> getSessionUser() async {
    String? sessionUserJson = await _secureStorage.read(key: 'session_user');
    if (sessionUserJson == null) return {};
    return jsonDecode(sessionUserJson);
  }

  Future<void> _loadUserData() async {
    final sessionUser = await getSessionUser();
    final name =
        '${sessionUser['nombres']} ${sessionUser['apellidos'] ?? 'Usuario'}';
    final email = sessionUser['correo'] ?? 'email@ejemplo.com';
    final codigo = sessionUser['codigo'] ?? 0;

    if (mounted) {
      setState(() {
        userName = name;
        userEmail = email;
        codigoUsuario = codigo;
      });
    }
  }

  Future<void> _printSecureStorageContent() async {
    final allValues = await _secureStorage.readAll();
    debugPrint('--- Secure Storage ---');
    allValues.forEach((key, value) {
      debugPrint('$key: $value');
    });
    debugPrint('----------------------');
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.read<AuthNotifier>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.edit2),
                      tooltip: 'Perfil de Usuario',
                      onPressed: () {
                        context.push('/home/edit-profile');
                      },
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.bug),
                      tooltip: 'Ver Storage',
                      onPressed: _printSecureStorageContent,
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.logOut),
                      tooltip: 'Cerrar sesión',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Cerrar sesión'),
                                content: const Text('¿Deseas cerrar sesión?'),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: const Text('Cerrar sesión'),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          await authNotifier.logout();
                          if (context.mounted) context.go('/login');
                        }
                      },
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        '¡Bienvenido,',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        userName ?? 'Usuario!',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 45,
                              backgroundImage: AssetImage(
                                'assets/images/user-icon.png',
                              ),
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/lg-icon-png.png',
                                    height: 80,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'SAVIAQUA',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Sistema de monitoreo inteligente de agua potable para juntas de potabilización pequeñas.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
