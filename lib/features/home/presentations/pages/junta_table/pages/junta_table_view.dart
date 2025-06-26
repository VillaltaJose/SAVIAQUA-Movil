import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:saviaqua/features/home/data/junta_data/junta_service.dart';
import 'package:saviaqua/features/home/model/junta/junta_model.dart';

class JuntaTableView extends StatefulWidget {
  const JuntaTableView({super.key});

  @override
  State<JuntaTableView> createState() => _JuntaTableViewState();
}

class _JuntaTableViewState extends State<JuntaTableView> {
  final JuntaService _juntaService = JuntaService();
  List<JuntaModel> _juntas = [];
  List<JuntaModel> _juntasFiltradas = [];

  bool _isLoading = true;
  String _busqueda = '';
  bool _isDesc = true;

  @override
  void initState() {
    super.initState();
    _fetchJuntas();
  }

  Future<void> _fetchJuntas() async {
    try {
      final filtros = {
        'minified': 'false',
        'pageSize': '50',
        'pageNumber': '1',
      };
      final datos = await _juntaService.getJuntasFiltrados(filtros);
      if (!mounted) return;
      setState(() {
        _juntas = datos;
        _filtrarJuntas();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR al cargar juntas: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _filtrarJuntas() {
    setState(() {
      _juntasFiltradas =
          _juntas.where((junta) {
            final termino = _busqueda.toLowerCase();
            return junta.nombre.toLowerCase().contains(termino) ||
                junta.provincia.toLowerCase().contains(termino) ||
                junta.ciudad.toLowerCase().contains(termino) ||
                junta.parroquia.toLowerCase().contains(termino);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Encabezado
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

              // Filtro de búsqueda y orden
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          onChanged: (value) {
                            _busqueda = value;
                            _filtrarJuntas();
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar Juntas...',
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
                              _juntas.sort(
                                (a, b) => b.nombre.compareTo(a.nombre),
                              );
                            } else {
                              _juntas.sort(
                                (a, b) => a.nombre.compareTo(b.nombre),
                              );
                            }
                            _isDesc = !_isDesc;
                            _filtrarJuntas();
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
                          // Aquí podrías abrir un diálogo de filtros si lo necesitas.
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
                          // Aquí podrías abrir un diálogo de filtros si lo necesitas.
                        },
                        child: const Icon(
                          Icons.add_home_work_outlined,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de juntas
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _juntasFiltradas.isEmpty
                        ? const Center(child: Text('No se encontraron juntas'))
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 8,
                          ),
                          itemCount: _juntasFiltradas.length,
                          itemBuilder: (_, index) {
                            final junta = _juntasFiltradas[index];
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
                                  // Aquí podrías hacer un push a una vista detalle si la tienes.
                                },
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading:
                                      junta.urlLogo != null
                                          ? ClipOval(
                                            child: Image.network(
                                              junta.urlLogo!,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : CircleAvatar(
                                            backgroundColor: Colors.blueAccent
                                                .withOpacity(0.1),
                                            child: const Icon(
                                              Icons.home_work_outlined,
                                              color: Colors.blueAccent,
                                              size: 24,
                                            ),
                                          ),
                                  title: Text(
                                    junta.nombre,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Ubicación: ${junta.provincia}, ${junta.ciudad}, ${junta.parroquia}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  trailing: Text(
                                    junta.codigo.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blueAccent,
                                    ),
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
