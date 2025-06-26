import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:saviaqua/features/home/data/user_data/user_service.dart';
import 'package:saviaqua/features/home/model/user/user-model.dart';

class UserTableView extends StatefulWidget {
  const UserTableView({super.key});

  @override
  State<UserTableView> createState() => _UserTableViewState();
}

class _UserTableViewState extends State<UserTableView> {
  final UserService _userService = UserService();
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];

  bool _isLoading = true;
  String _search = '';
  bool _isDesc = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await _userService.getUsers();
      if (!mounted) return;
      setState(() {
        _users = data;
        _filteredUsers = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR al cargar usuarios: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers =
          _users.where((user) {
            final query = _search.toLowerCase();
            return user.nombres.toLowerCase().contains(query) ||
                user.apellidos.toLowerCase().contains(query) ||
                user.correo.toLowerCase().contains(query) ||
                user.rol.toLowerCase().contains(query) ||
                user.junta.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Image.asset(
                  'assets/images/lg-horizontal.png',
                  fit: BoxFit.cover,
                  height: 50,
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          onChanged: (value) {
                            _search = value;
                            _filterUsers();
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar Usuarios...',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 8,
                              ),
                              child: Icon(
                                LucideIcons.search,
                                size: 20,
                                color: Colors.black38,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black38),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          cursorColor: Colors.black38,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_isDesc) {
                              _users.sort(
                                (a, b) => b.nombres.compareTo(a.nombres),
                              );
                            } else {
                              _users.sort(
                                (a, b) => a.nombres.compareTo(b.nombres),
                              );
                            }
                            _isDesc = !_isDesc;
                            _filterUsers();
                          });
                        },
                        child: const Icon(
                          Icons.swap_vert,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    SizedBox(
                      height: 40,
                      width: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Implement filter functionality
                        },
                        child: const Icon(
                          Icons.tune,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    SizedBox(
                      height: 40,
                      width: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          context.push('/home/add-junta');
                        },
                        child: const Icon(
                          LucideIcons.userPlus,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // User list
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredUsers.isEmpty
                        ? const Center(
                          child: Text('No se encontraron usuarios'),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (_, index) {
                            final user = _filteredUsers[index];
                            return Card(
                              elevation: 6,
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1.5,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  // Push a la vista del usuario
                                },
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.withOpacity(
                                      0.1,
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  title: Text(
                                    '${user.nombres} ${user.apellidos}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(user.correo),
                                      Text('Rol: ${user.rol}'),
                                      Text('Junta: ${user.junta}'),
                                      Text(
                                        'Creado: ${user.fechaCreacion.toLocal().toString().substring(0, 10)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
