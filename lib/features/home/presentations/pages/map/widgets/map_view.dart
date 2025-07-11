import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:saviaqua/core/widgets/loading_overlay.dart';
import 'package:saviaqua/features/home/data/pozo_data/pozo_service.dart';
import 'package:saviaqua/features/home/data/pozo_detail_data/pozo_details_service.dart';
import 'package:saviaqua/features/home/model/pozo/pozo_model.dart';
import 'package:saviaqua/features/home/model/pozo_details/pozo_details_model.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _mapController;
  bool isLoading = true;

  final LatLng _center = const LatLng(-1.8312, -78.1834);
  final PozoService _pozoService = PozoService();

  Set<Marker> _markers = {};
  late BitmapDescriptor _customIcon;
  bool isLoadingDetails = true;
  String errorDetails = '';
  final PozoDetailsService _pozoDetailsService = PozoDetailsService();
  PozoDetailsModel? pozoDetailsModel;
  bool filtersApplied = false;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    final byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _loadCustomMarker() async {
    try {
      final bytes = await getBytesFromAsset(
        'assets/images/punto_agua2.png',
        80,
      );
      _customIcon = BitmapDescriptor.fromBytes(bytes);
      fetchPozos();
    } catch (e) {
      debugPrint("ERROR al cargar el icono personalizado: $e");
    }
  }

  Future<void> fetchPozos({Map<String, String>? filtros}) async {
    if (mounted) setState(() => isLoading = true);
    if (filtros != null) {
      filtersApplied = true;
    } else {
      filtersApplied = false;
    }
    try {
      final pozos =
          filtros == null
              ? await _pozoService.getPozos()
              : await _pozoService.getPozosFiltrados(filtros);

      final markers =
          pozos.map((pozo) {
            return Marker(
              markerId: MarkerId(pozo.codigo.toString()),
              position: LatLng(pozo.latitude, pozo.longitude),
              icon: _customIcon,
              infoWindow: InfoWindow(title: pozo.nombre),
              onTap: () => _onMarkerTapped(pozo),
            );
          }).toSet();

      if (mounted) setState(() => _markers = markers);

      if (pozos.isNotEmpty) {
        if (pozos.length == 1) {
          final target = LatLng(pozos.first.latitude, pozos.first.longitude);
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: target, zoom: 14.0),
            ),
          );
        } else {
          final bounds = _getBounds(pozos);
          _mapController.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 100),
          );
        }
      }
    } catch (e) {
      debugPrint("ERROR al cargar pozos: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchPozoDetailById(int pozoId) async {
    if (mounted) {
      setState(() {
        isLoadingDetails = true;
      });
    }

    try {
      final data = await _pozoDetailsService.getMeasurementByPozoId(pozoId);
      if (mounted) {
        setState(() {
          isLoadingDetails = false;
          pozoDetailsModel = data;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoadingDetails = false;
          errorDetails = 'Error al cargar los detalles del pozo.';
        });
      }
    }
  }

  Color _getCloroColor(double cloro) {
    if (cloro < 0.2) return Colors.blue;
    if (cloro <= 2.0) return Colors.green;
    return Colors.red;
  }

  LatLngBounds _getBounds(List<PozoModel> pozos) {
    final swLat = pozos.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final swLng = pozos.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    final neLat = pozos.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final neLng = pozos.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    return LatLngBounds(
      southwest: LatLng(swLat, swLng),
      northeast: LatLng(neLat, neLng),
    );
  }

  void _onMarkerTapped(PozoModel pozo) async {
    _fetchPozoDetailById(pozo.codigo);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder:
          (_) => Container(
            padding: const EdgeInsets.all(16),
            height: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pozo.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  '${pozo.ciudad}, ${pozo.provincia} - ${pozo.parroquia}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),

                if (pozoDetailsModel != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _getCloroColor(
                        pozoDetailsModel!.cloroResidual,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 24,
                          color: _getCloroColor(
                            pozoDetailsModel!.cloroResidual,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cloro residual: ${pozoDetailsModel!.cloroResidual.toStringAsFixed(2)} ppm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _getCloroColor(
                                    pozoDetailsModel!.cloroResidual,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Medido el: ${pozoDetailsModel!.fechaRegistro.toLocal().toString().substring(0, 19)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      context.push('/home/pozo/${pozo.codigo}');
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Ver más',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Cargando mapa...',
      style: LoadingStyle.drop,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 6.5),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _mapController = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),
          if (!isLoading && _markers.isEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(12),
                color: Colors.redAccent.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No se encontraron pozos',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      filtersApplied
                          ? const SizedBox.shrink()
                          : TextButton(
                            onPressed: () {
                              fetchPozos();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white24,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Recargar'),
                          ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
