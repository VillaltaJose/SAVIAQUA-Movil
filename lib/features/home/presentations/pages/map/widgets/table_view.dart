  import 'package:flutter/material.dart';

class TableView extends StatelessWidget {
  const TableView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista simulada de juntas
    final List<Map<String, String>> juntas = [
      {
        'nombre': 'Junta San Pedro',
        'provincia': 'Tungurahua',
        'estado': 'Activa',
      },
      {
        'nombre': 'Junta La Esperanza',
        'provincia': 'Manabí',
        'estado': 'En mantenimiento',
      },
      {
        'nombre': 'Junta Río Verde',
        'provincia': 'Pichincha',
        'estado': 'Sin conexión',
      },
    ];

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: juntas.length,
        itemBuilder: (_, index) {
          final junta = juntas[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.water_drop_outlined, color: Colors.blueAccent),
              title: Text(junta['nombre'] ?? ''),
              subtitle: Text('Provincia: ${junta['provincia'] ?? ''}'),
              trailing: Text(
                junta['estado'] ?? '',
                style: TextStyle(
                  color: junta['estado'] == 'Activa'
                      ? Colors.green
                      : junta['estado'] == 'Sin conexión'
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
              onTap: () {
                // Navegar a detalles
              },
            ),
          );
        },
      ),
    );
  }
}
