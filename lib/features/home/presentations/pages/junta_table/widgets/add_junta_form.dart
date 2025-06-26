import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:saviaqua/features/home/data/junta_data/junta_service.dart';
import 'package:saviaqua/features/home/data/location_data/location_service.dart';
import 'package:saviaqua/features/home/model/junta/Junta_DTO.dart';
import 'package:saviaqua/features/home/model/location/place_model.dart';
import 'package:saviaqua/features/home/presentations/widgets/generic_widgets.dart';
import 'package:saviaqua/features/home/presentations/widgets/minimap_preview.dart';
import 'package:saviaqua/features/home/presentations/widgets/select_location_map.dart';

class JuntaForm extends StatefulWidget {
  const JuntaForm({super.key});

  @override
  State<JuntaForm> createState() => _JuntaFormState();
}

class _JuntaFormState extends State<JuntaForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  bool _ubicacionInvalida = false;

  final LocationService _locationService = LocationService();
  final JuntaService _juntaService = JuntaService();

  List<LugarModel> provincias = [];
  List<LugarModel> ciudades = [];
  List<LugarModel> parroquias = [];

  int? selectedProvinciaId;
  int? selectedCiudadId;
  int? selectedParroquiaId;

  bool _isLoadingProvincias = true;
  bool _isLoadingCiudades = false;
  bool _isLoadingParroquias = false;

  bool _isLoading = false;

  bool usarCoordenadasManual = true;

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
    _loadProvincias();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  Future<void> _loadProvincias() async {
    try {
      final res = await _locationService.getProvincias();
      setState(() => provincias = res.value);
    } catch (e) {
      debugPrint('Error al cargar provincias: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProvincias = false;
          selectedProvinciaId = null;
          selectedCiudadId = null;
          selectedParroquiaId = null;
          ciudades = [];
          parroquias = [];
        });
      }
    }
  }

  Future<void> _loadCiudades(int codigoProvincia) async {
    setState(() {
      _isLoadingCiudades = true;
      ciudades = [];
      selectedCiudadId = null;
      parroquias = [];
      selectedParroquiaId = null;
    });
    try {
      final res = await _locationService.getCiudades(codigoProvincia);
      setState(() => ciudades = res.value);
    } catch (e) {
      debugPrint('Error al cargar ciudades: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingCiudades = false);
      }
    }
  }

  Future<void> _loadParroquias(int codigoProvincia, int codigoCiudad) async {
    setState(() {
      _isLoadingParroquias = true;
      parroquias = [];
      selectedParroquiaId = null;
    });
    try {
      final res = await _locationService.getParroquias(
        codigoProvincia,
        codigoCiudad,
      );
      setState(() => parroquias = res.value);
    } catch (e) {
      debugPrint('Error al cargar parroquias: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingParroquias = false);
      }
    }
  }

  void _toggleUbicacion(bool usarManual) {
    setState(() {
      usarCoordenadasManual = usarManual;
      _latController.clear();
      _lngController.clear();
    });
  }

  void _submitForm() async {
    final formValid = _formKey.currentState!.validate();
    final ubicacionValida =
        _latController.text.isNotEmpty && _lngController.text.isNotEmpty;

    setState(() {
      _ubicacionInvalida = !ubicacionValida;
    });

    if (!formValid || !ubicacionValida) {
      return;
    }

    setState(() => _isLoading = true);

    final dataDTO = CreateJuntaDTO(
      nombre: _nombreController.text.trim(),
      descripcion:
          _descripcionController.text.trim() == ''
              ? null
              : _descripcionController.text.trim(),
      codigoProvincia: selectedProvinciaId,
      codigoCiudad: selectedCiudadId,
      codigoParroquia: selectedParroquiaId,
      latitude: double.tryParse(_latController.text.trim()),
      longitude: double.tryParse(_lngController.text.trim()),
    );

    try {
      await _juntaService.createJunta(dataDTO);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Junta registrado exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al registrar el Junta: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
       if (mounted) {
          context.pop();
          context.go('/home/juntas?refresh=${DateTime.now().millisecondsSinceEpoch}');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Guardando Junta...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : Container(
                color: Colors.white,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildSectionCard(
                            title: 'Información Básica',
                            icon: Icons.info_outline,
                            children: [
                              buildAnimatedField(
                                delay: 100,
                                child: inputField(
                                  _nombreController,
                                  'Nombre del Junta',
                                  'Ej. Junta Azuay',
                                  Icons.water_drop,
                                  validator: true,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          buildSectionCard(
                            title: 'Ubicación Geográfica',
                            icon: Icons.location_on,
                            children: [
                              buildAnimatedField(
                                delay: 200,
                                child: buildDropdown(
                                  isLoading: _isLoadingProvincias,
                                  value: selectedProvinciaId,
                                  items:
                                      provincias
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e.codigo,
                                              child: Text(e.nombre),
                                            ),
                                          )
                                          .toList(),
                                  hintLoading: 'Cargando provincias...',
                                  label: 'Provincia',
                                  icon: Icons.map,
                                  onChanged: (val) {
                                    setState(() => selectedProvinciaId = val);
                                    if (val != null) _loadCiudades(val);
                                  },
                                  validator:
                                      (val) =>
                                          val == null
                                              ? 'Seleccione una provincia'
                                              : null,
                                ),
                              ),

                              const SizedBox(height: 16),

                              buildAnimatedField(
                                delay: 300,
                                child: buildDropdown(
                                  isLoading: _isLoadingCiudades,
                                  value: selectedCiudadId,
                                  items:
                                      selectedProvinciaId == null
                                          ? [
                                            const DropdownMenuItem(
                                              value: null,
                                              child: Text(
                                                'Seleccione una provincia',
                                              ),
                                            ),
                                          ]
                                          : ciudades
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e.codigo,
                                                  child: Text(e.nombre),
                                                ),
                                              )
                                              .toList(),
                                  hintLoading: 'Cargando ciudades...',
                                  label: 'Ciudad',
                                  icon: Icons.location_city,
                                  onChanged: (val) {
                                    setState(() => selectedCiudadId = val);
                                    if (val != null &&
                                        selectedProvinciaId != null) {
                                      _loadParroquias(
                                        selectedProvinciaId!,
                                        val,
                                      );
                                    }
                                  },
                                  validator:
                                      (val) =>
                                          selectedProvinciaId != null &&
                                                  !_isLoadingCiudades &&
                                                  val == null
                                              ? 'Seleccione una ciudad'
                                              : null,
                                ),
                              ),

                              const SizedBox(height: 16),

                              buildAnimatedField(
                                delay: 400,
                                child: buildDropdown(
                                  isLoading: _isLoadingParroquias,
                                  value: selectedParroquiaId,
                                  items:
                                      selectedCiudadId == null
                                          ? [
                                            const DropdownMenuItem(
                                              value: null,
                                              child: Text(
                                                'Seleccione una ciudad',
                                              ),
                                            ),
                                          ]
                                          : parroquias
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e.codigo,
                                                  child: Text(e.nombre),
                                                ),
                                              )
                                              .toList(),
                                  hintLoading: 'Cargando parroquias...',
                                  label: 'Parroquia',
                                  icon: Icons.home,
                                  onChanged:
                                      (val) => setState(
                                        () => selectedParroquiaId = val,
                                      ),
                                  validator:
                                      (val) =>
                                          selectedCiudadId != null &&
                                                  !_isLoadingParroquias &&
                                                  val == null
                                              ? 'Seleccione una parroquia'
                                              : null,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          buildSectionCard(
                            title: 'Coordenadas',
                            icon: Icons.gps_fixed,
                            children: [
                              buildAnimatedField(
                                delay: 500,
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ToggleButtons(
                                      isSelected: [
                                        usarCoordenadasManual,
                                        !usarCoordenadasManual,
                                      ],
                                      onPressed:
                                          (i) => _toggleUbicacion(i == 0),
                                      borderRadius: BorderRadius.circular(12),
                                      selectedColor: Colors.white,
                                      fillColor: Colors.blue,
                                      color: Colors.grey.shade600,
                                      constraints: BoxConstraints(
                                        minWidth:
                                            (MediaQuery.of(context).size.width -
                                                90) /
                                            2,
                                        minHeight: 45,
                                      ),
                                      children: const [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit_location, size: 18),
                                            SizedBox(width: 4),
                                            Text('Manual'),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.map, size: 18),
                                            SizedBox(width: 4),
                                            Text('Mapa'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              if (usarCoordenadasManual) ...[
                                buildAnimatedField(
                                  delay: 600,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: inputField(
                                          _latController,
                                          'Latitud',
                                          'Ej. -2.90055',
                                          null,
                                          validator: true,
                                          isNumber: true,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: inputField(
                                          _lngController,
                                          'Longitud',
                                          'Ej. -79.00453',
                                          null,
                                          validator: true,
                                          isNumber: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                buildAnimatedField(
                                  delay: 600,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: SizedBox(
                                      height: 200,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Positioned.fill(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (_latController
                                                        .text
                                                        .isNotEmpty &&
                                                    _lngController
                                                        .text
                                                        .isNotEmpty) ...[
                                                  MiniMapPreview(
                                                    key: ValueKey(
                                                      '${_latController.text}_${_lngController.text}',
                                                    ),
                                                    lat: double.parse(
                                                      _latController.text,
                                                    ),
                                                    lng: double.parse(
                                                      _lngController.text,
                                                    ),
                                                    height: 200,
                                                  ),
                                                ] else ...[
                                                  Icon(
                                                    Icons.map,
                                                    size: 48,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    _ubicacionInvalida
                                                        ? 'Debe seleccionar la ubicación'
                                                        : 'Vista del mapa próximamente',
                                                    style: TextStyle(
                                                      color:
                                                          _ubicacionInvalida
                                                              ? Colors.red
                                                              : Colors
                                                                  .grey
                                                                  .shade600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 50),
                                                ],
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) =>
                                                            const SelectLocationPage(),
                                                  ),
                                                );

                                                if (result is LatLng) {
                                                  setState(() {
                                                    _latController.text = result
                                                        .latitude
                                                        .toStringAsFixed(6);
                                                    _lngController.text = result
                                                        .longitude
                                                        .toStringAsFixed(6);
                                                  });
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.my_location,
                                              ),
                                              label: Text(
                                                _latController.text.isEmpty
                                                    ? 'Seleccionar ubicación'
                                                    : 'Cambiar ubicación',
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 16),

                          buildSectionCard(
                            title: 'Observaciones',
                            icon: Icons.note_alt,
                            children: [
                              buildAnimatedField(
                                delay: 700,
                                child: TextFormField(
                                  controller: _descripcionController,
                                  maxLines: 4,
                                  decoration: inputDecoration(
                                    'Detalles adicionales sobre el Junta...',
                                    null,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          buildAnimatedField(
                            delay: 800,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1,
                                ),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _submitForm,
                                icon: const Icon(
                                  Icons.save_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Guardar Junta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.blue,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
