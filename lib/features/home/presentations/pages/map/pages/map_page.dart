import 'package:flutter/material.dart';
import 'package:saviaqua/features/home/presentations/pages/map/widgets/map_toggle_view.dart';
import 'package:saviaqua/features/home/presentations/pages/map/widgets/table_view.dart';
import '../widgets/map_view.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _showMap = true;

  void _toggleView() {
    setState(() {
      _showMap = !_showMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Vista dinámica: mapa o tabla
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showMap ? const MapView() : const TableView(),
          ),

          // // Botón de filtros (arriba derecha)
          // const Positioned(
          //   top: 40,
          //   right: 16,
          //   child: MapFiltersButton(),
          // ),

          // // Botón para alternar entre tabla y mapa (abajo derecha)
          Positioned(
            bottom: 24,
            right: 16,
            child: MapToggleButtons(
              showMap: _showMap,
              onToggle: _toggleView,
            ),
          ),
        ],
      ),
    );
  }
}
