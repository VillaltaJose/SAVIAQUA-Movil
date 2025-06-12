import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
      backgroundColor: Colors.white,
      tooltip: showMap ? 'Ver como tabla' : 'Ver en mapa',
      child: Icon(showMap ? LucideIcons.table : LucideIcons.map, size: 28, color: Colors.black38),
    );
  }
}
