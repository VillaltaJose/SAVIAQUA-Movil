import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:saviaqua/features/home/presentations/pages/map/widgets/map_toggle_view.dart';
import 'package:saviaqua/features/home/presentations/pages/map/widgets/table_view.dart';
import '../widgets/map_view.dart';
import '../widgets/map_filters_sheet.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final GlobalKey<MapViewState> _mapKey = GlobalKey<MapViewState>();
  bool _showMap = true;

  void _toggleView() {
    setState(() {
      _showMap = !_showMap;
    });
  }

  void _abrirFiltros() async {
  final filtros = await showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const MapFiltersSheet(),
  );

  if (filtros != null && mounted) {
    await Future.delayed(const Duration(milliseconds: 100));
    _mapKey.currentState?.fetchPozos(filtros: filtros);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showMap ? MapView(key: _mapKey) : const TableView(),
          ),

          Positioned(
            top: 40,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_showMap)
                  FloatingActionButton(
                    heroTag: 'filters_button',
                    onPressed: _abrirFiltros,
                    tooltip: 'Aplicar filtros',
                    backgroundColor: Colors.white,
                    child: Icon(
                      LucideIcons.filter,
                      size: 28,
                      color: Colors.black38,
                    ),
                  ),
                const SizedBox(height: 12),
                MapToggleButtons(showMap: _showMap, onToggle: _toggleView),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
