import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saviaqua/features/home/presentations/pages/junta_table/widgets/add_junta_form.dart';

class AddJuntaPage extends StatelessWidget {
  const AddJuntaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Agregar una nueva Junta',
          style: const TextStyle(color: Colors.blue),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: JuntaForm(),
      ),
      );
  }
}
