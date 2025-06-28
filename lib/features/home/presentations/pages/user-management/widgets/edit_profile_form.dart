import 'package:flutter/material.dart';
import 'package:saviaqua/features/home/data/profile_data/profile_service.dart';
import 'package:saviaqua/features/home/model/profile/profile-model.dart';
import 'package:saviaqua/features/home/presentations/widgets/generic_widgets.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _juntaController = TextEditingController();
  final _roleController = TextEditingController();

  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _repeatPassController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoadingUser = true;
  ProfileModel? _profile;

  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _profileService.getProfileProfile();
      if (!mounted || user == null) return;

      setState(() {
        _profile = user;
        _nameController.text = user.nombres;
        _lastnameController.text = user.apellidos;
        _emailController.text = user.correo;
        _juntaController.text = user.junta;
        _roleController.text = user.rol;
        _isLoadingUser = false;
      });

      _animationController.forward();
    } catch (e) {
      debugPrint('Error al cargar usuario: $e');
      if (mounted) {
        setState(() => _isLoadingUser = false);
      }
    }
  }

  void _submitForm() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    if (_newPassController.text != _repeatPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // llamado para actualizar el perfil
    debugPrint(
      'Actualizar perfil: ${_nameController.text} ${_lastnameController.text}',
    );
  }

  bool _hasUppercase(String value) => value.contains(RegExp(r'[A-Z]'));
  bool _hasLowercase(String value) => value.contains(RegExp(r'[a-z]'));
  bool _hasDigit(String value) => value.contains(RegExp(r'[0-9]'));
  bool _hasSpecial(String value) => value.contains(RegExp(r'[!@#\$&*~%^]'));

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    if (_profile == null) {
      return const Center(
        child: Text('No se pudo cargar la información del usuario.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildSectionCard(
                title: 'Información básica',
                icon: Icons.person,
                children: [
                  buildAnimatedField(
                    delay: 100,
                    child: inputField(
                      _nameController,
                      'Nombres',
                      'Ej. Daniel',
                      Icons.person,
                      validator: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildAnimatedField(
                    delay: 200,
                    child: inputField(
                      _lastnameController,
                      'Apellidos',
                      'Ej. Pérez',
                      Icons.person_outline,
                      validator: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildAnimatedField(
                    delay: 300,
                    child: inputField(
                      _emailController,
                      'Correo electrónico',
                      'Ej. daniel.perez@example.com',
                      Icons.email,
                      validator: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              buildSectionCard(
                title: 'Información institucional',
                icon: Icons.business,
                children: [
                  buildAnimatedField(
                    delay: 400,
                    child: inputField(
                      _juntaController,
                      'Junta',
                      'Ej. Junta de Vecinos',
                      Icons.home_work,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildAnimatedField(
                    delay: 500,
                    child: inputField(
                      _roleController,
                      'Rol',
                      'Ej. Administrador',
                      Icons.verified_user,
                      readOnly: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              buildSectionCard(
                title: 'Cambiar contraseña',
                icon: Icons.lock_outline,
                children: [
                  buildAnimatedField(
                    delay: 600,
                    child: inputField(
                      _oldPassController,
                      'Contraseña anterior',
                      '',
                      Icons.lock,
                      validator: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildAnimatedField(
                    delay: 700,
                    child: inputField(
                      _newPassController,
                      'Nueva contraseña',
                      '',
                      Icons.lock_open,
                      validator: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildAnimatedField(
                    delay: 750,
                    child: inputField(
                      _repeatPassController,
                      'Repita su nueva contraseña',
                      '',
                      Icons.lock_outline,
                      validator: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordRules(),
                ],
              ),

              const SizedBox(height: 32),

              buildAnimatedField(
                delay: 800,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Guardar cambios',
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

  Widget _buildPasswordRules() {
    final password = _newPassController.text;
    final rules = {
      'Mínimo 8 caracteres': password.length >= 8,
      'Al menos una letra mayúscula': _hasUppercase(password),
      'Al menos una letra minúscula': _hasLowercase(password),
      'Al menos un número': _hasDigit(password),
      'Al menos un caracter especial': _hasSpecial(password),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          rules.entries.map((entry) {
            return Row(
              children: [
                Icon(
                  entry.value ? Icons.check_circle : Icons.cancel,
                  color: entry.value ? Colors.green : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 13,
                    color: entry.value ? Colors.green : Colors.red,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}
