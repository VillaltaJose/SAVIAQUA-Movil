import 'package:flutter/material.dart';
import 'package:saviaqua/features/home/data/user_data/user_service.dart';
import 'package:saviaqua/features/home/model/user/user-model.dart';
import 'package:saviaqua/features/home/presentations/pages/user-management/widgets/user_form.dart';

class EditUserPage extends StatefulWidget {
  final int userId;

  const EditUserPage({super.key, required this.userId});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  bool isLoading = true;
  UserModel? user;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final userData = await UserService().getUserById(widget.userId);
      setState(() {
        user = userData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error al cargar usuario: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Usuario',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : UserForm(user: user),
    );
  }
}
