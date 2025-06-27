import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:saviaqua/features/home/data/location_data/location_service.dart';
import 'package:saviaqua/features/home/data/pozo_data/pozo_service.dart';
import 'package:saviaqua/features/home/model/location/place_model.dart';
import 'package:saviaqua/features/home/model/pozo/pozo_model.dart';

class GenericFiltersSheet extends StatefulWidget {
  final bool showJunta;
  final bool showProvincia;
  final bool showCiudad;
  final bool showParroquia;

  const GenericFiltersSheet({
    super.key,
    this.showJunta = false,
    this.showProvincia = false,
    this.showCiudad = false,
    this.showParroquia = false,
  });

  @override
  State<GenericFiltersSheet> createState() => _GenericFiltersSheetState();
}

class _GenericFiltersSheetState extends State<GenericFiltersSheet> {
  final LocationService _locationService = LocationService();
  final PozoService _pozoService = PozoService();

  bool _isLoadingCiudades = false;
  bool _isLoadingProvincias = false;
  bool _isLoadingParroquias = false;
  bool _isLoadingJuntas = false;

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
    if (widget.showProvincia) _loadProvincias();
    if (widget.showJunta) _fetchPozos();
  }

  Future<void> _loadProvincias() async {
    setState(() => _isLoadingProvincias = true);
    try {
      final res = await _locationService.getProvincias();
      provincias = res.value;
    } catch (e) {
      debugPrint('Error al cargar provincias: $e');
    } finally {
      if (mounted) setState(() => _isLoadingProvincias = false);
    }
  }

  Future<void> _loadCiudades({int? codigoProvincia}) async {
    setState(() => _isLoadingCiudades = true);
    try {
      final res =
          codigoProvincia != null
              ? await _locationService.getCiudades(codigoProvincia)
              : await _locationService.getAllCiudades();
      ciudades = res.value;
    } catch (e) {
      debugPrint('Error al cargar ciudades: $e');
    } finally {
      if (mounted) setState(() => _isLoadingCiudades = false);
    }
  }

  Future<void> _loadParroquias({
    int? codigoProvincia,
    int? codigoCiudad,
  }) async {
    setState(() => _isLoadingParroquias = true);
    try {
      final res =
          (codigoProvincia != null && codigoCiudad != null)
              ? await _locationService.getParroquias(
                codigoProvincia,
                codigoCiudad,
              )
              : await _locationService.getAllParroquias();
      parroquias = res.value;
    } catch (e) {
      debugPrint('Error al cargar parroquias: $e');
    } finally {
      if (mounted) setState(() => _isLoadingParroquias = false);
    }
  }

  Future<void> _fetchPozos() async {
    setState(() => _isLoadingJuntas = true);
    try {
      juntas = await _pozoService.getPozos();
    } catch (e) {
      debugPrint("ERROR al cargar pozos: $e");
    } finally {
      if (mounted) setState(() => _isLoadingJuntas = false);
    }
  }

  void _applyFilter() {
    final filtros = <String, String>{};

    if (widget.showJunta && selectedJuntaId != null) {
      filtros['codigoJunta'] = '$selectedJuntaId';
    }
    if (widget.showProvincia) {
      filtros['codigoProvincia'] = selectedProvinciaId?.toString() ?? 'null';
    }
    if (widget.showCiudad) {
      filtros['codigoCiudad'] = selectedCiudadId?.toString() ?? 'null';
    }
    if (widget.showParroquia) {
      filtros['codigoParroquia'] = selectedParroquiaId?.toString() ?? 'null';
    }

    filtros['pageSize'] = '15';
    filtros['pageNumber'] = '1';

    Navigator.pop(context, filtros);
  }

  void _clearFilters() {
    setState(() {
      selectedProvinciaId = null;
      selectedCiudadId = null;
      selectedParroquiaId = null;
      selectedJuntaId = null;
      ciudades.clear();
      parroquias.clear();
    });

    Navigator.pop(context, {});
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
    );
  }

  DropdownMenuItem<int> _loadingItem(String text) {
    return DropdownMenuItem(
      value: null,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
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

            if (widget.showJunta) ...[
              DropdownButtonFormField<int>(
                value: selectedJuntaId,
                decoration: _buildDropdownDecoration(
                  'Junta',
                  LucideIcons.mapPin,
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                items:
                    _isLoadingJuntas
                        ? [_loadingItem('Cargando juntas...')]
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
                        : (v) => setState(() => selectedJuntaId = v),
              ),
              const SizedBox(height: 12),
            ],

            if (widget.showProvincia) ...[
              DropdownButtonFormField<int>(
                value: selectedProvinciaId,
                decoration: _buildDropdownDecoration(
                  'Provincia',
                  LucideIcons.building2,
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                items:
                    _isLoadingProvincias
                        ? [_loadingItem('Cargando provincias...')]
                        : provincias
                            .map(
                              (p) => DropdownMenuItem(
                                value: p.codigo,
                                child: Text(p.nombre),
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
                            ciudades.clear();
                            parroquias.clear();
                          });
                          if (widget.showCiudad)
                            _loadCiudades(codigoProvincia: value);
                        },
              ),
              const SizedBox(height: 12),
            ],

            if (widget.showCiudad) ...[
              DropdownButtonFormField<int>(
                value: selectedCiudadId,
                decoration: _buildDropdownDecoration(
                  'Ciudad',
                  LucideIcons.home,
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                items:
                    _isLoadingCiudades
                        ? [_loadingItem('Cargando ciudades...')]
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
                            parroquias.clear();
                          });
                          if (widget.showParroquia) {
                            _loadParroquias(
                              codigoProvincia:
                                  widget.showProvincia
                                      ? selectedProvinciaId
                                      : null,
                              codigoCiudad: value,
                            );
                          }
                        },
              ),
              const SizedBox(height: 12),
            ],

            if (widget.showParroquia) ...[
              DropdownButtonFormField<int>(
                value: selectedParroquiaId,
                decoration: _buildDropdownDecoration(
                  'Parroquia',
                  LucideIcons.mapPin,
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                items:
                    _isLoadingParroquias
                        ? [_loadingItem('Cargando parroquias...')]
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
                        : (value) =>
                            setState(() => selectedParroquiaId = value),
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _applyFilter,
                  icon: const Icon(LucideIcons.search, color: Colors.white),
                  label: const Text(
                    'Aplicar filtros',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _clearFilters,
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
