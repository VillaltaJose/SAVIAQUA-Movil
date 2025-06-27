import 'package:flutter/material.dart';
import 'package:saviaqua/features/home/data/junta_data/junta_service.dart';
import 'package:saviaqua/features/home/model/junta/junta_model.dart';
import 'package:saviaqua/features/home/model/user/user-model.dart';
import 'package:saviaqua/features/home/presentations/widgets/generic_widgets.dart';

class UserForm extends StatefulWidget {
  final UserModel? user;
  final bool isReadOnly;

  const UserForm({
    super.key,
    this.user,
    this.isReadOnly = false,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();

  String? selectedRole;
  int? selectedJuntaId;

  List<JuntaModel> juntas = [];
  bool isLoadingJuntas = true;
  bool isLoading = false;

  final List<String> roles = ['Administrador', 'Técnico', 'Supervisor'];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool get isReadOnly => widget.isReadOnly;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.user != null) {
      _nameController.text = widget.user!.nombres;
      _lastnameController.text = widget.user!.apellidos;
      _emailController.text = widget.user!.correo;
      selectedRole = widget.user!.rol;
    }

    await _fetchJuntas();

    if (widget.user != null) {
      final match = juntas.firstWhere(
        (j) => j.nombre == widget.user!.junta,
        orElse: () => juntas.first,
      );
      selectedJuntaId = match.codigo;
    }
  }

  Future<void> _fetchJuntas() async {
    try {
      final res = await JuntaService().getJuntasFiltrados({'minified': 'true'});
      if (mounted) setState(() => juntas = res);
    } catch (e) {
      debugPrint('ERROR al cargar juntas: $e');
    } finally {
      if (mounted) setState(() => isLoadingJuntas = false);
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (selectedRole == null || selectedJuntaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un rol y una junta')),
      );
      return;
    }

    final userData = {
      'nombres': _nameController.text.trim(),
      'apellidos': _lastnameController.text.trim(),
      'correo': _emailController.text.trim(),
      'rol': selectedRole,
      'codigoJunta': selectedJuntaId,
    };

    debugPrint(widget.user == null
        ? 'Nuevo usuario: $userData'
        : 'Usuario actualizado: $userData');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildSectionCard(
                title: 'Información del usuario',
                icon: Icons.person,
                children: [
                  buildAnimatedField(
                    delay: 100,
                    child: inputField(
                      _nameController,
                      'Nombre',
                      'Ej. Juan',
                      Icons.person,
                      validator: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildAnimatedField(
                    delay: 150,
                    child: inputField(
                      _lastnameController,
                      'Apellido',
                      'Ej. Pérez',
                      Icons.person_outline,
                      validator: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildAnimatedField(
                    delay: 200,
                    child: inputField(
                      _emailController,
                      'Correo electrónico',
                      'Ej. juan@mail.com',
                      Icons.email,
                      validator: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildAnimatedField(
                    delay: 250,
                    child: AbsorbPointer(
                      absorbing: isReadOnly,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rol',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedRole,
                            items: roles
                                .map((role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(role),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedRole = val),
                            validator: (val) =>
                                val == null ? 'Seleccione un rol' : null,
                            decoration: inputDecoration(
                                'Seleccione una opción', Icons.security),
                            disabledHint: selectedRole != null
                                ? Text(selectedRole!)
                                : const Text('Sin asignar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildAnimatedField(
                    delay: 300,
                    child: AbsorbPointer(
                      absorbing: isReadOnly,
                      child: buildDropdown(
                        isLoading: isLoadingJuntas,
                        value: selectedJuntaId,
                        items: juntas
                            .map(
                              (j) => DropdownMenuItem(
                                value: j.codigo,
                                child: Text(j.nombre),
                              ),
                            )
                            .toList(),
                        hintLoading: 'Cargando juntas...',
                        label: 'Junta',
                        icon: Icons.home_work,
                        onChanged: (val) =>
                            setState(() => selectedJuntaId = val),
                        validator: (val) =>
                            val == null ? 'Seleccione una junta' : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (!isReadOnly)
                buildAnimatedField(
                  delay: 400,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'Guardar usuario',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
