import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saviaqua/features/home/data/pozo_data/pozo_service.dart';
import 'package:saviaqua/features/home/data/pozo_detail_data/pozo_details_service.dart';
import 'package:saviaqua/features/home/model/pozo/pozo_model.dart';
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

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _fetchPozo();
    _fetchPozoDetails();
  }

  Future<void> _fetchPozo() async {
    try {
      final fetchedPozo = await _pozoService.getPozoById(widget.pozoId);
      if (mounted) {
        setState(() {
          isLoadingPozo = false;
          if (fetchedPozo == null) {
            errorPozo = 'Pozo no encontrado';
          } else {
            pozo = fetchedPozo;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoadingPozo = false;
          errorPozo = 'Error al cargar el pozo';
        });
      }
    }
  }

  Future<void> _fetchPozoDetails({DateTime? inicio, DateTime? fin}) async {
    final now = DateTime.now();
    final lastMonth = now.subtract(const Duration(days: 30));

    final filtros = {
      'codigoPozo': widget.pozoId.toString(),
      'fechaInicio': (inicio ?? lastMonth).toIso8601String(),
      'fechaFin': (fin ?? now).toIso8601String(),
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
            ultimaMedida = data.last;
            historialParaGrafico =
                data.length > 1 ? data.sublist(0, data.length - 1) : [];
          } else {
            errorDetails = 'No se encontraron mediciones para este pozo.';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoadingDetails = false;
          errorDetails = 'Error al cargar los detalles del pozo.';
        });
      }
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          startDate != null && endDate != null
              ? DateTimeRange(start: startDate!, end: endDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });

      await _fetchPozoDetails(inicio: startDate!, fin: endDate!);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    
    if (isLoadingPozo || isLoadingDetails) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          pozo?.nombre ?? 'Detalles del Pozo',
          style: const TextStyle(color: Colors.blue),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pozo != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${pozo!.ciudad}, ${pozo!.provincia} - ${pozo!.parroquia}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            if (errorPozo.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorPozo,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        startDate != null && endDate != null
                            ? '${_formatDate(startDate!)} - ${_formatDate(endDate!)}'
                            : 'Seleccionar rango de fechas',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              startDate != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            if (ultimaMedida != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Última medición: ${ultimaMedida!.fechaRegistro.toLocal().toString().substring(0, 19)}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
            const SizedBox(height: 16),
            if (ultimaMedida != null) _buildCloroPanel(ultimaMedida!),
            if (ultimaMedida == null && errorDetails.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  errorDetails,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            if (ultimaMedida != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMeasureCard(
                    'Med 1',
                    '${ultimaMedida!.m1}',
                    Icons.thermostat,
                  ),
                  _buildMeasureCard(
                    'Med 2',
                    '${ultimaMedida!.m2}',
                    Icons.bolt,
                  ),
                  _buildMeasureCard('Med 3',
                    '${ultimaMedida!.m3}',
                    Icons.water_drop),
                    
                  _buildMeasureCard(
                    'Med 4',
                    '${ultimaMedida!.m4}',
                    Icons.bolt,
                  ),
                ],
              ),
            const SizedBox(height: 24),
            const Text(
              'Tendencia de cloro residual',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 400,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: ResidualChlorineChart(historial: historialParaGrafico),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloroPanel(PozoDetailsModel medida) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
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
            '${medida.cloroResidual.toStringAsFixed(2)} ppm',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: _getCloroColor(medida.cloroResidual),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getCloroEstado(medida.cloroResidual),
            style: const TextStyle(fontSize: 14),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
