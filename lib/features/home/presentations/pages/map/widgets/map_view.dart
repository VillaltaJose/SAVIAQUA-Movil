import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:saviaqua/features/home/data/pozo_service.dart';
import 'package:saviaqua/features/home/model/pozo_model.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller = Completer();
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
      _fetchPozos(); // cargar después del ícono
    } catch (e) {
      debugPrint("ERROR al cargar el icono personalizado: $e");
    }
  }

  Future<void> _fetchPozos() async {
    try {
      final pozos = await _pozoService.getPozos();
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
    } catch (e) {
      debugPrint("ERROR al cargar pozos: $e");
    }
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
      onMapCreated: (GoogleMapController controller) => _controller.complete(controller),
      markers: _markers,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
    );
  }
}
