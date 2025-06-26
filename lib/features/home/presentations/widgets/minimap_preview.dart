import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MiniMapPreview extends StatelessWidget {
  final double lat;
  final double lng;
  final double height;

  const MiniMapPreview({super.key, required this.lat, required this.lng, required this.height});

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(lat, lng);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: position,
            zoom: 12,
          ),
          markers: {
            Marker(
              markerId: const MarkerId("pozoPreview"),
              position: position,
            ),
          },
          zoomControlsEnabled: false,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: false,
          myLocationEnabled: false,
          onMapCreated: (controller) {},
        ),
      ),
    );
  }
}
