import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationPage extends StatefulWidget {
  const SelectLocationPage({super.key});

  @override
  State<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  LatLng? selectedLocation;
  // ignore: unused_field
  GoogleMapController? _mapController;

  final LatLng initialPosition = const LatLng(-1.8312, -78.1834);

  void _onMapTapped(LatLng position) {
    setState(() {
      selectedLocation = position;
    });
  }

  void _confirmSelection() {
    if (selectedLocation != null) {
      Navigator.pop(context, selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una ubicación en el mapa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar ubicación')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: initialPosition, zoom: 6),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTapped,
            markers: selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: selectedLocation!,
                    )
                  }
                : {},
          ),
          Positioned(
            bottom: 16,
            right: 16,
            left: 16,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Confirmar ubicación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _confirmSelection,
            ),
          ),
        ],
      ),
    );
  }
}
