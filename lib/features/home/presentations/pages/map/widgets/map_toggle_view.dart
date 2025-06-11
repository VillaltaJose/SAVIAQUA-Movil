import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MapToggleButtons extends StatelessWidget {
  final bool showMap;
  final VoidCallback onToggle;

  const MapToggleButtons({
    super.key,
    required this.showMap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onToggle,
      child: Icon(showMap ? Icons.table_chart : Icons.map),
      tooltip: showMap ? 'Ver como tabla' : 'Ver en mapa',
    );
  }
}
