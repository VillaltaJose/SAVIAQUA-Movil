import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saviaqua/features/auth/data/auth_notifier.dart';
import 'package:saviaqua/features/auth/data/auth_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<String> errors = [];
  bool loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      loading = true;
      errors.clear();
    });

    final authService = AuthService();
    final authNotifier = context.read<AuthNotifier>();

    try {
      final result = await authService.login(email, password);
      final token = result['token'];
      final user = result['perfilUsuario'];

      await authNotifier.login(
        token,
        user,
      );

      if (!context.mounted) return;
      context.go('/home');
    } catch (e) {
      final mensaje =
          e is Exception
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Ocurrió un error inesperado.';
      _mostrarModalError(mensaje);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  bool _obscureText = true;

  void _mostrarModalError(String mensaje) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            titlePadding: const EdgeInsets.all(16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            actionsPadding: const EdgeInsets.only(right: 8, bottom: 8),
            title: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.red, size: 28),
                SizedBox(width: 10),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            content: Text(
              mensaje,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Aceptar'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              labelStyle: TextStyle(color: Colors.black38),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black38, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              
            ),
            cursorColor: Colors.black38,
            style: const TextStyle(fontSize: 14),
            keyboardType: TextInputType.emailAddress,
            // validator:
            //     (value) =>
            //         value == null || !value.contains('@')
            //             ? 'Correo inválido'
            //             : null,
            onSaved: (value) => email = value!.trim(),
            onChanged: (value) {
              setState(() {
                _formKey.currentState!.validate();
              });
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            decoration: InputDecoration(
              labelText: 'Contraseña',
              labelStyle: const TextStyle(color: Colors.black38),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black38, width: 1),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 1),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 1),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            cursorColor: Colors.black38,
            obscureText: _obscureText,
            // validator:
            //     (value) =>
            //         value == null || value.length < 6
            //             ? 'Mínimo 6 caracteres'
            //             : null,
            onSaved: (value) => password = value!.trim(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              child: const Text('Iniciar sesión'),
            ),
          ),
        ],
      ),
    );
  }
}
