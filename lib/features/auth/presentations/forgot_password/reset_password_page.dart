import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String code;

  const ResetPasswordPage({super.key, required this.email, required this.code});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPassController = TextEditingController();
  final _repeatPassController = TextEditingController();
  bool _isResetting = false;
  bool _obscureText = true;

  bool _validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$');
    return regex.hasMatch(password);
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPassController.text != _repeatPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _isResetting = true);

    try {
      final newPassword = _newPassController.text.trim();
      debugPrint('Restableciendo contraseña para ${widget.email}');
      // await AuthService().resetPassword(widget.email, widget.code, newPassword);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente')),
      );
      context.go('/login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Image.asset('assets/images/lg-horizontal-png.png', height: 50),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.lock,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Restablecer contraseña',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa tu nueva contraseña segura',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _newPassController,
                            decoration: InputDecoration(
                              labelText: 'Nueva contraseña',
                              hintText: 'Escribe una nueva contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              labelStyle: TextStyle(color: Colors.black38),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black38,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              if (!_validatePassword(value)) {
                                return 'Contraseña insegura';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _repeatPassController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Confirmar contraseña',
                              hintText: 'Repite tu contraseña',
                              prefixIcon: const Icon(Icons.lock),
                              labelStyle: TextStyle(color: Colors.black38),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black38,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'La nueva contraseña debe contener:\n\n'
                              '• Mínimo 8 caracteres\n'
                              '• Al menos una mayúscula\n'
                              '• Al menos una minúscula\n'
                              '• Un número\n'
                              '• Un caracter especial',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isResetting ? null : _resetPassword,
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar nueva contraseña'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E8EDF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
