import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:saviaqua/features/home/data/pozo_data/pozo_service.dart';
import 'package:saviaqua/features/home/model/pozo/pozo_model.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _mapController;

  final LatLng _center = const LatLng(-1.8312, -78.1834);
  final PozoService _pozoService = PozoService();

  Set<Marker> _markers = {};
  late BitmapDescriptor _customIcon;

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
      final bytes = await getBytesFromAsset('assets/images/punto_agua2.png', 80);
      _customIcon = BitmapDescriptor.fromBytes(bytes);
      fetchPozos();
    } catch (e) {
      debugPrint("ERROR al cargar el icono personalizado: $e");
    }
  }

  Future<void> fetchPozos({Map<String, String>? filtros}) async {
    try {
      final pozos = filtros == null
          ? await _pozoService.getPozos()
          : await _pozoService.getPozosFiltrados(filtros);

      final markers = pozos.map((pozo) {
        return Marker(
          markerId: MarkerId(pozo.codigo.toString()),
          position: LatLng(pozo.latitude, pozo.longitude),
          icon: _customIcon,
          infoWindow: InfoWindow(title: pozo.nombre),
          onTap: () => _onMarkerTapped(pozo),
        );
      }).toSet();

      setState(() => _markers = markers);

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
          _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
        }
      }
    } catch (e) {
      debugPrint("ERROR al cargar pozos: $e");
    }
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

  void _onMarkerTapped(PozoModel pozo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pozo.nombre,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Provincia: ${pozo.provincia}\nCantón: ${pozo.ciudad}\nParroquia: ${pozo.parroquia}',
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: navegar a detalle del pozo
                },
                child: const Text('Ver más'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _center, zoom: 6.5),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        _mapController = controller;
      },
      markers: _markers,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
    );
  }
}
