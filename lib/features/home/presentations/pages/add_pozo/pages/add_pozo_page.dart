import 'package:flutter/material.dart';

class AddPozoPage extends StatelessWidget {
  const AddPozoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar nuevo pozo'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          // child: PozoForm(),
        ),
      ),
    );
  }
}
