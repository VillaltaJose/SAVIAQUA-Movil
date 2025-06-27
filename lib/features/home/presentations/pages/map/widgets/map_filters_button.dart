import 'package:flutter/material.dart';
import '../../../widgets/generic_filters_sheet.dart';

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
          builder: (_) => const GenericFiltersSheet(
            showJunta: true,
            showProvincia: true,
            showCiudad: true,
            showParroquia: true,
          ),
        );
      },
      tooltip: 'Filtros',
      child: const Icon(Icons.filter_alt),
    );
  }
}
