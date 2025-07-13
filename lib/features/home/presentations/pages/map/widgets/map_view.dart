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
  LatLng? _currentLocation;
  bool _locationPermissionGranted = false;

  Set<Polyline> _polylines = {};

  String? _routeDistance;
  String? _routeDuration;
  List<dynamic>? _routeSteps;
  String? _legStartAddress;
  String? _legEndAddress;
  bool _isRoutePanelVisible = false;
  PozoModel? _pozoConRuta;
  bool _isAtMaxHeight = false;

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
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$dest&key=$apiKey&language=es';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final routes = data['routes'];
        if (routes == null || routes.isEmpty) {
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

        final leg = routes[0]['legs'][0];
        print('Leg: $leg');
        _routeDistance = leg['distance']['text'];
        _routeDuration = leg['duration']['text'];
        _routeSteps = leg['steps'];
        _legStartAddress = leg['start_address'];
        _legEndAddress = leg['end_address'];

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

  String _parseHtml(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
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
            height: 280, 
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                        Navigator.pop(context);
                        _mostrarRutaEnPanel(pozo);
                      },
                      icon: const Icon(
                        Icons.map,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Ver Ruta',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

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

  void _mostrarRutaEnPanel(PozoModel pozo) async {
    await _getRoutePolyline(LatLng(pozo.latitude, pozo.longitude));

    if (!mounted) return;

    setState(() {
      _pozoConRuta = pozo;
      _isRoutePanelVisible = true;
    });
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
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          if (_locationPermissionGranted && _currentLocation != null)
            Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton(
                heroTag: 'current_location',
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
          if (_isRoutePanelVisible && _pozoConRuta != null) ...[
            DraggableScrollableSheet(
              initialChildSize: 0.15,
              minChildSize: 0.15,
              maxChildSize: 0.80,
              builder: (context, scrollController) {
                return NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    setState(() {
                      _isAtMaxHeight = notification.extent >= 0.27;
                    });
                    return true;
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 60,
                      left: 16,
                      right: 16,
                    ),

                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  _pozoConRuta!.nombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isRoutePanelVisible = false;
                                      _pozoConRuta = null;
                                      _routeDistance = null;
                                      _routeDuration = null;
                                      _polylines.clear();
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.black87,
                                    size: 15,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                          if (_routeDistance != null && _routeDuration != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(top: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.blueGrey.shade100,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.route,
                                            color: Colors.blue,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'Resumen de la ruta',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.timer,
                                            size: 20,
                                            color: Colors.black54,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$_routeDuration',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Icon(
                                            Icons.social_distance,
                                            size: 20,
                                            color: Colors.black54,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$_routeDistance',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const Divider(height: 24, thickness: 1.2),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Desde: ${_legStartAddress ?? "N/A"}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.flag,
                                            color: Colors.redAccent,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Hasta: ${_legEndAddress ?? "N/A"}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                const Text(
                                  'Instrucciones paso a paso:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                if (_routeSteps != null)
                                  Column(
                                    children:
                                        _routeSteps!.asMap().entries.expand((
                                          entry,
                                        ) {
                                          final index = entry.key + 1;
                                          final step = entry.value;
                                          String instructionText = _parseHtml(
                                            step['html_instructions'],
                                          );
                                          final stepDistance =
                                              step['distance']?['text'] ?? '';
                                          final icon = _getStepIcon(
                                            instructionText,
                                          );
                                          final isLastStep =
                                              entry.key ==
                                              _routeSteps!.length - 1;

                                          String? destinationPhrase;
                                          final destinoRegex = RegExp(
                                            r'(tu destino está.*|has llegado.*|you have arrived.*|your destination is.*|El destino es.*)',
                                            caseSensitive: false,
                                          );
                                          final match = destinoRegex.firstMatch(
                                            instructionText,
                                          );
                                          if (isLastStep && match != null) {
                                            destinationPhrase = match.group(0);
                                            instructionText =
                                                instructionText
                                                    .replaceAll(
                                                      destinationPhrase!,
                                                      '',
                                                    )
                                                    .trim();
                                          }

                                          List<Widget> widgets = [];

                                          if (instructionText.isNotEmpty) {
                                            widgets.add(
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                padding: const EdgeInsets.all(
                                                  14,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: Colors
                                                                .grey
                                                                .shade300,
                                                  ),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 3,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:Colors
                                                                    .blue
                                                                    .shade100,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      child: Icon(icon,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 14),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text('Paso $index',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:Colors
                                                                          .blueGrey
                                                                          .shade700,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            instructionText,
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              height: 1.4,
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                            ),
                                                          ),
                                                          if (stepDistance
                                                                  .isNotEmpty)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 6,
                                                                  ),
                                                              child: Row(
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .straighten,
                                                                    size: 16,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 6,
                                                                  ),
                                                                  Text(
                                                                    stepDistance,
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color:
                                                                          Colors
                                                                              .black54,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }

                                          if (destinationPhrase != null &&
                                              destinationPhrase.isNotEmpty) {
                                            widgets.add(
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                padding: const EdgeInsets.all(
                                                  14,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color:
                                                        Colors.green.shade400,
                                                  ),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 3,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      child: const Icon(
                                                        Icons.flag,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 14),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Llegada',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors
                                                                      .green
                                                                      .shade900,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            destinationPhrase,
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              height: 1.4,
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }

                                          return widgets;
                                        }).toList(),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: const BorderSide(color: Colors.black12, width: 1.5),
                    top:
                        _isAtMaxHeight
                            ? const BorderSide(
                              color: Colors.black12,
                              width: 1.5,
                            )
                            : BorderSide.none,
                  ),
                ),
                padding: const EdgeInsets.only(
                  top: 2,
                  bottom: 5,
                  left: 40,
                  right: 40,
                ),
                child: SafeArea(
                  top: false,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0.3,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: () {
                      _openNavigation(
                        _pozoConRuta!.latitude,
                        _pozoConRuta!.longitude,
                      );
                    },
                    icon: const Icon(
                      Icons.directions,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Cómo llegar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

IconData _getStepIcon(String instruction) {
  instruction = instruction.toLowerCase();
  if (instruction.contains("walk") || instruction.contains("caminar")) {
    return Icons.directions_walk;
  } else if (instruction.contains("turn right") ||
      instruction.contains("gira a la derecha")) {
    return Icons.turn_slight_right;
  } else if (instruction.contains("turn left") ||
      instruction.contains("gira a la izquierda")) {
    return Icons.turn_slight_left;
  } else if (instruction.contains("head") ||
      instruction.contains("sigue recto")) {
    return Icons.straight;
  } else if (instruction.contains("bus") ||
      instruction.contains("transporte público")) {
    return Icons.directions_bus;
  } else if (instruction.contains("bike") ||
      instruction.contains("bicicleta")) {
    return Icons.directions_bike;
  } else {
    return Icons.navigation;
  }
}
