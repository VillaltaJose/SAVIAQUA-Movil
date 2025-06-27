import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saviaqua/features/home/presentations/pages/user-management/widgets/user_form.dart';

class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Agregar un nuevo Usuario',
          style: const TextStyle(color: Colors.blue),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: UserForm(),
      ),
      );
  }
}
