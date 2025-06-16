import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saviaqua/features/home/data/pozo_data/pozo_service.dart';
import 'package:saviaqua/features/home/data/pozo_detail_data/pozo_details_service.dart';
import 'package:saviaqua/features/home/model/pozo/pozo_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:saviaqua/features/home/model/pozo_details/pozo_details_model.dart';
import 'package:saviaqua/features/home/presentations/pages/pozo_detail/widgets/residual_chlorine_chart.dart';

class PozoDetailsPage extends StatefulWidget {
  final int pozoId;

  const PozoDetailsPage({super.key, required this.pozoId});

  @override
  State<PozoDetailsPage> createState() => _PozoDetailsPageState();
}

class _PozoDetailsPageState extends State<PozoDetailsPage> {
  final PozoService _pozoService = PozoService();
  final PozoDetailsService _pozoDetailsService = PozoDetailsService();

  PozoModel? pozo;
  List<PozoDetailsModel> pozoDetails = [];
  PozoDetailsModel? ultimaMedida;
  List<PozoDetailsModel> historialParaGrafico = [];

  bool isLoadingPozo = true;
  bool isLoadingDetails = true;
  String errorPozo = '';
  String errorDetails = '';

  @override
  void initState() {
    super.initState();
    _fetchPozo();
    _fetchPozoDetails();
  }

  Future<void> _fetchPozo() async {
    try {
      final fetchedPozo = await _pozoService.getPozoById(widget.pozoId);

      if (fetchedPozo == null) {
        if (mounted) {
          setState(() {
            isLoadingPozo = false;
            errorPozo = 'Pozo no encontrado';
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          pozo = fetchedPozo;
          isLoadingPozo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingPozo = false;
          errorPozo = 'Error al cargar el pozo';
        });
      }
    }
  }

  Future<void> _fetchPozoDetails() async {
    final now = DateTime.now();
    final lastMonth = now.subtract(const Duration(days: 30));

    final filtros = {
      'codigoPozo': widget.pozoId.toString(),
      'fechaInicio': lastMonth.toIso8601String(),
      'fechaFin': now.toIso8601String(),
    };

    if (mounted) {
      setState(() {
        isLoadingDetails = true;
        errorDetails = '';
        pozoDetails = [];
        ultimaMedida = null;
        historialParaGrafico = [];
      });
    }

    try {
      final data = await _pozoDetailsService.getMeasurements(filtros);

      if (mounted) {
        setState(() {
          isLoadingDetails = false;
          if (data.isNotEmpty) {
            pozoDetails = data;
            ultimaMedida = pozoDetails.last;
            if (pozoDetails.length > 1) {
              historialParaGrafico = pozoDetails.sublist(0, pozoDetails.length - 1);
            }
          } else {
            errorDetails = 'No se encontraron mediciones para este pozo.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingDetails = false;
          errorDetails = 'Error al cargar los detalles del pozo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingPozo || isLoadingDetails) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pozo?.nombre ?? 'Detalles del Pozo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // UBICACIÓN
            if (pozo != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${pozo!.ciudad}, ${pozo!.provincia} - ${pozo!.parroquia}',
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                ],
              ),

            if (errorPozo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(errorPozo, style: const TextStyle(color: Colors.red)),
              ),

            const SizedBox(height: 12),

            // PANEL CLORO
            if (ultimaMedida != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Cloro residual',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${ultimaMedida!.m1.toStringAsFixed(2)} ppm',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _getCloroColor(ultimaMedida!.m1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCloroEstado(ultimaMedida!.m1),
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),

            if (ultimaMedida == null && errorDetails.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(errorDetails, style: const TextStyle(color: Colors.red)),
              ),

            const SizedBox(height: 20),

            // MEDIDAS EXTRA
            if (ultimaMedida != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMeasureCard('Temp', '${ultimaMedida!.m2} °C', Icons.thermostat),
                  _buildMeasureCard('ORP', '${ultimaMedida!.m3} mV', Icons.bolt),
                  _buildMeasureCard('Oxígeno', 'N/D', Icons.water_drop),
                ],
              ),

            const SizedBox(height: 24),

            const Text(
              'Tendencia de medidas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<String>(
                  value: 'día',
                  items: const [
                    DropdownMenuItem(value: 'día', child: Text('Día')),
                    DropdownMenuItem(value: 'semana', child: Text('Semana')),
                    DropdownMenuItem(value: 'mes', child: Text('Mes')),
                    DropdownMenuItem(value: 'año', child: Text('Año')),
                  ],
                  onChanged: (value) {
                    // TODO: aplicar filtro gráfico
                  },
                ),
              ],
            ),

            Container(
              height: 200,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              alignment: Alignment.center,
              child: ResidualChlorineChart(historial: historialParaGrafico),
            ),

            const SizedBox(height: 24),

            Center(
              child: TextButton.icon(
                onPressed: () {
                  // TODO: Navegar a historial o medida individual
                },
                icon: const Icon(LucideIcons.history),
                label: const Text('Ver historial completo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCloroColor(double cloro) {
    if (cloro < 0.2) return Colors.red;
    if (cloro < 0.5) return Colors.orange;
    if (cloro <= 2.0) return Colors.green;
    return Colors.red;
  }

  String _getCloroEstado(double cloro) {
    if (cloro < 0.2) return 'Muy bajo';
    if (cloro < 0.5) return 'Precaución';
    if (cloro <= 2.0) return 'Normal';
    return 'Alto';
  }

  Widget _buildMeasureCard(String label, String value, IconData icon) {
    return GestureDetector(
      onTap: () {
        // TODO: mostrar gráfico de esa medida
      },
      child: Column(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
