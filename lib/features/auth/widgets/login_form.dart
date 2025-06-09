import 'package:flutter/material.dart';
import 'package:saviaqua/config/router.dart';

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      router.go('/home');
      print('Email: $email | Password: $password');
    }
  }

  bool _obscureText = true;

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
                backgroundColor: Colors.blue, // Color del botón
                foregroundColor: Colors.white, // Color del texto
                //boton activado
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Opción para darle bordes redondeados
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
