import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:saviaqua/features/home/data/pozo_data/pozo_service.dart';
import 'package:saviaqua/features/home/model/pozo/pozo_model.dart';
import '../../../widgets/generic_filters_sheet.dart';

class TableView extends StatefulWidget {
  const TableView({super.key});

  @override
  State<TableView> createState() => _TableViewState();
}

class _TableViewState extends State<TableView> {
  final PozoService _pozoService = PozoService();
  List<PozoModel> _pozos = [];
  List<PozoModel> _pozosFiltrados = [];

  bool _isLoading = true;
  String _busqueda = '';
  bool _isDesc = true;

  @override
  void initState() {
    super.initState();
    _fetchPozos();
  }

  Future<void> _fetchPozos([Map<String, String>? filtros]) async {
    try {
      final datos =
          filtros == null
              ? await _pozoService.getPozos()
              : await _pozoService.getPozosFiltrados(filtros);
      if (!mounted) return;
      setState(() {
        _pozos = datos;
        _filtrarPozos();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('Error al cargar pozos: $e');
    }
  }

  void _filtrarPozos() {
    setState(() {
      _pozosFiltrados =
          _pozos.where((pozo) {
            final termino = _busqueda.toLowerCase();
            return pozo.nombre.toLowerCase().contains(termino) ||
                pozo.provincia.toLowerCase().contains(termino) ||
                pozo.ciudad.toLowerCase().contains(termino) ||
                pozo.junta.toLowerCase().contains(termino);
          }).toList();
    });
  }

  void _abrirFiltro() async {
    final filtros = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const GenericFiltersSheet(mostrarCampoJunta: true),
    );

    if (filtros != null) {
      debugPrint('Filtros aplicados: $filtros');
      _fetchPozos(filtros);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
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
                            _filtrarPozos();
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar Pozos...',
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
                              _pozos.sort(
                                (a, b) => b.nombre.compareTo(a.nombre),
                              );
                            } else {
                              _pozos.sort(
                                (a, b) => a.nombre.compareTo(b.nombre),
                              );
                            }
                            _isDesc = !_isDesc;
                            _filtrarPozos();
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
                        onPressed: _abrirFiltro,
                        child: const Icon(
                          Icons.tune,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _pozosFiltrados.isEmpty
                        ? const Center(child: Text('No se encontraron pozos'))
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 8,
                          ),
                          itemCount: _pozosFiltrados.length,
                          itemBuilder: (_, index) {
                            final pozo = _pozosFiltrados[index];
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
                                  context.push('/home/pozo/${pozo.codigo}');
                                },
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueAccent
                                        .withOpacity(0.1),
                                    child: const Icon(
                                      Icons.water_drop_outlined,
                                      color: Colors.blueAccent,
                                      size: 28,
                                    ),
                                  ),
                                  title: Text(
                                    pozo.nombre,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ubicación: ${pozo.provincia}, ${pozo.ciudad}, ${pozo.parroquia}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Junta: ${pozo.junta}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black38,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    pozo.codigo.toString(),
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
