import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  const VerifyCodePage({super.key, required this.email});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isVerifying = false;

  void _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isVerifying = true);

    try {
      final code = _codeController.text.trim();
      debugPrint('Verificando código $code para ${widget.email}');
      // await AuthService().verifyCode(widget.email, code);

      if (!mounted) return;
      context.push('/forgot-password/reset?email=${widget.email}&code=$code');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código inválido: $e')),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
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
                    LucideIcons.shieldCheck,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verifica tu código',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hemos enviado un código al correo\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.blue.shade800,
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
                            controller: _codeController,
                            decoration: InputDecoration(
                              labelText: 'Código de verificación',
                              hintText: 'Ej. 123456',
                              labelStyle: const TextStyle(color: Colors.black38),
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
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              prefixIcon: const Icon(Icons.lock_clock_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            cursorColor: Colors.black38,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Este campo es requerido';
                              }
                              if (value.length < 4) {
                                return 'Debe tener al menos 4 dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isVerifying ? null : _verifyCode,
                              icon: const Icon(Icons.verified),
                              label: const Text('Verificar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
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
