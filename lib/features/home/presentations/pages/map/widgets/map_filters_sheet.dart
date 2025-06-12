import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:saviaqua/features/home/data/location_service.dart';
import 'package:saviaqua/features/home/data/pozo_service.dart';
import 'package:saviaqua/features/home/model/place_model.dart';
import 'package:saviaqua/features/home/model/pozo_model.dart';

class MapFiltersSheet extends StatefulWidget {
  const MapFiltersSheet({super.key});

  @override
  State<MapFiltersSheet> createState() => _MapFiltersSheetState();
}

class _MapFiltersSheetState extends State<MapFiltersSheet> {
  final LocationService _locationService = LocationService();
  final PozoService _pozoService = PozoService();

  bool _isLoadingCiudades = true;
  bool _isLoadingProvincias = true;
  bool _isLoadingParroquias = true;
  bool _isLoadingJuntas = true;

  int? selectedProvinciaId;
  int? selectedCiudadId;
  int? selectedParroquiaId;
  int? selectedJuntaId;

  List<LugarModel> provincias = [];
  List<LugarModel> ciudades = [];
  List<LugarModel> parroquias = [];
  List<PozoModel> juntas = [];

  @override
  void initState() {
    super.initState();
    _loadProvincias();
    _fetchPozos();
  }

  Future<void> _loadProvincias() async {
    try {
      final res = await _locationService.getProvincias();
      setState(() => provincias = res.value);
    } catch (e) {
      debugPrint('Error al cargar provincias: $e');
    } finally {
      setState(() => _isLoadingProvincias = false);
    }
  }

  Future<void> _loadCiudades(int codigoProvincia) async {
    try {
      final res = await _locationService.getCiudades(codigoProvincia);
      setState(() => ciudades = res.value);
    } catch (e) {
      debugPrint('Error al cargar ciudades: $e');
    } finally {
      setState(() => _isLoadingCiudades = false);
    }
  }

  Future<void> _loadParroquias(int codigoProvincia, int codigoCiudad) async {
    try {
      final res = await _locationService.getParroquias(
        codigoProvincia,
        codigoCiudad,
      );
      setState(() => parroquias = res.value);
    } catch (e) {
      debugPrint('Error al cargar parroquias: $e');
    } finally {
      setState(() => _isLoadingParroquias = false);
    }
  }

  Future<void> _fetchPozos() async {
    try {
      final res = await _pozoService.getPozos();
      setState(() => juntas = res);
    } catch (e) {
      debugPrint("ERROR al cargar pozos: $e");
    } finally {
      setState(() => _isLoadingJuntas = false);
    }
  }

  void _aplicarFiltro() {
    final filtros = <String, String>{};

    if (selectedJuntaId != null) filtros['codigoJunta'] = '$selectedJuntaId';
    if (selectedProvinciaId != null) {
      filtros['codigoProvincia'] = '$selectedProvinciaId';
    } else {
      filtros['codigoProvincia'] = 'null';
    }
    if (selectedCiudadId != null) {
      filtros['codigoCiudad'] = '$selectedCiudadId';
    } else {
      filtros['codigoCiudad'] = 'null';
    }
    if (selectedParroquiaId != null) {
      filtros['codigoParroquia'] = '$selectedParroquiaId';
    } else {
      filtros['codigoParroquia'] = 'null';
    }

    if (filtros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un filtro')),
      );
      return;
    }

    filtros['pageSize'] = '15';
    filtros['pageNumber'] = '1';

    Navigator.pop(context, filtros);
  }

  InputDecoration _buildDropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
      prefixIcon: Icon(icon, size: 20, color: Colors.grey[700]),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: selectedJuntaId,
              decoration: _buildDropdownDecoration('Junta', LucideIcons.mapPin),
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              menuMaxHeight: 300,
              items:
                  _isLoadingJuntas
                      ? [
                        const DropdownMenuItem(
                          value: null,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Cargando juntas...'),
                            ],
                          ),
                        ),
                      ]
                      : juntas
                          .map(
                            (j) => DropdownMenuItem(
                              value: j.codigo,
                              child: Text(j.nombre),
                            ),
                          )
                          .toList(),
              onChanged:
                  _isLoadingJuntas
                      ? null
                      : (value) => setState(() => selectedJuntaId = value),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: selectedProvinciaId,
              decoration: _buildDropdownDecoration(
                'Provincia',
                LucideIcons.building2,
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              menuMaxHeight: 300,
              items:
                  _isLoadingProvincias
                      ? [
                        const DropdownMenuItem(
                          value: null,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Cargando provincias...'),
                            ],
                          ),
                        ),
                      ]
                      : provincias
                          .map(
                            (prov) => DropdownMenuItem(
                              value: prov.codigo,
                              child: Text(prov.nombre),
                            ),
                          )
                          .toList(),
              onChanged:
                  _isLoadingProvincias
                      ? null
                      : (value) {
                        setState(() {
                          selectedProvinciaId = value;
                          selectedCiudadId = null;
                          selectedParroquiaId = null;
                          _isLoadingCiudades = true;
                          _isLoadingParroquias = false;
                          ciudades = [];
                          parroquias = [];
                        });
                        if (value != null) _loadCiudades(value);
                      },
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              value: selectedCiudadId,
              decoration: _buildDropdownDecoration('Ciudad', LucideIcons.home),
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              menuMaxHeight: 300,
              items:
                  _isLoadingCiudades
                      ? [
                        const DropdownMenuItem(
                          value: null,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Cargando ciudades...'),
                            ],
                          ),
                        ),
                      ]
                      : ciudades
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.codigo,
                              child: Text(c.nombre),
                            ),
                          )
                          .toList(),
              onChanged:
                  _isLoadingCiudades
                      ? null
                      : (value) {
                        setState(() {
                          selectedCiudadId = value;
                          selectedParroquiaId = null;
                          _isLoadingParroquias = true;
                          parroquias = [];
                        });
                        if (value != null && selectedProvinciaId != null) {
                          _loadParroquias(selectedProvinciaId!, value);
                        }
                      },
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              value: selectedParroquiaId,
              decoration: _buildDropdownDecoration(
                'Parroquia',
                LucideIcons.mapPin,
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              menuMaxHeight: 300,
              items:
                  _isLoadingParroquias
                      ? [
                        const DropdownMenuItem(
                          value: null,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Cargando parroquias...'),
                            ],
                          ),
                        ),
                      ]
                      : parroquias
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.codigo,
                              child: Text(p.nombre),
                            ),
                          )
                          .toList(),
              onChanged:
                  _isLoadingParroquias
                      ? null
                      : (value) => setState(() => selectedParroquiaId = value),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _aplicarFiltro,
                  icon: const Icon(LucideIcons.search, color: Colors.white),
                  label: const Text(
                    'Aplicar filtros',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _aplicarFiltro,
                  icon: const Icon(LucideIcons.trash, color: Colors.white),
                  label: const Text(
                    'Limpiar filtros',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
