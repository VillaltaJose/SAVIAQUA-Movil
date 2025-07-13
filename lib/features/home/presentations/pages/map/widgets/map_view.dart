import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // Variables para ubicación actual
  LatLng? _currentLocation;
  bool _locationPermissionGranted = false;

  // linea de ruta
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _locationPermissionGranted = true;
        });
      }
    } catch (e) {
      debugPrint("Error al obtener ubicación: $e");
    }
  }

  Future<void> _openNavigation(double lat, double lng) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${_currentLocation!.latitude},${_currentLocation!.longitude}'
        '&destination=$lat,$lng&travelmode=driving';
    final Uri url = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la navegación')),
        );
      }
    }
  }

  Future<void> _getRoutePolyline(LatLng destination) async {
    if (_currentLocation == null) return;

    final String apiKey = dotenv.env['API_KEY_GOOGLE_MAPS'] ?? '';
    final origin =
        '${_currentLocation!.latitude},${_currentLocation!.longitude}';
    final dest = '${destination.latitude},${destination.longitude}';

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$dest&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final routes = data['routes'];
        if (routes == null || routes.isEmpty) {
          print(response.body);
          debugPrint('No se encontró una ruta.');
          return;
        }

        final overviewPolyline = routes[0]['overview_polyline'];
        final points = overviewPolyline['points'];

        final decodedPoints = PolylinePoints().decodePolyline(points);
        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 6,
          points:
              decodedPoints
                  .map((e) => LatLng(e.latitude, e.longitude))
                  .toList(),
        );

        setState(() => _polylines = {polyline});

        final bounds = LatLngBounds(
          southwest: LatLng(
            _currentLocation!.latitude < destination.latitude
                ? _currentLocation!.latitude
                : destination.latitude,
            _currentLocation!.longitude < destination.longitude
                ? _currentLocation!.longitude
                : destination.longitude,
          ),
          northeast: LatLng(
            _currentLocation!.latitude > destination.latitude
                ? _currentLocation!.latitude
                : destination.latitude,
            _currentLocation!.longitude > destination.longitude
                ? _currentLocation!.longitude
                : destination.longitude,
          ),
        );

        _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
      } else {
        debugPrint('Error en la Directions API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error obteniendo ruta: $e');
    }
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
            height: 280, // Aumentado para el botón de navegación
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

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón ver ruta
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _getRoutePolyline(
                          LatLng(pozo.latitude, pozo.longitude),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.route,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Ver ruta',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    // Botón de navegación
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _openNavigation(pozo.latitude, pozo.longitude);
                      },
                      icon: const Icon(
                        Icons.directions,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Cómo llegar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    // Botón ver más
                    ElevatedButton.icon(
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
                  ],
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
            polylines: _polylines,
            markers: _markers,
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),

          // Botón para centrar en ubicación actual
          if (_locationPermissionGranted && _currentLocation != null)
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () {
                  if (_currentLocation != null) {
                    _mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: _currentLocation!, zoom: 14.0),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.my_location, color: Colors.blue),
              ),
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
