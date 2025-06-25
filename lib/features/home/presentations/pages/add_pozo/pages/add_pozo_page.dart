import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saviaqua/features/home/presentations/pages/add_pozo/widgets/add_pozo_form.dart';

class AddPozoPage extends StatelessWidget {
  const AddPozoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Agregar un nuevo pozo',
          style: const TextStyle(color: Colors.blue),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => context.pop(),
        ),
      ),
      body:SingleChildScrollView(
          child: PozoForm(),
        ),
      );
  }
}
