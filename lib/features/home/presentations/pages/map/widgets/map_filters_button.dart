import 'package:flutter/material.dart';
import 'map_filters_sheet.dart';

class MapFiltersButton extends StatelessWidget {
  const MapFiltersButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'filters_button',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const MapFiltersSheet(),
        );
      },
      tooltip: 'Filtros',
      child: const Icon(Icons.filter_alt),
    );
  }
}
