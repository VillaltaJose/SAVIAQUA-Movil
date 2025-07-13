import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:saviaqua/core/widgets/loading_overlay.dart';
import 'package:saviaqua/features/home/data/pozo_detail_data/pozo_details_service.dart';
import 'package:saviaqua/features/home/model/pozo/pozo_model.dart';
import 'package:saviaqua/features/home/model/pozo_details/pozo_details_model.dart';

class PozoDetailsBottomSheet extends StatefulWidget {
  final PozoModel pozo;
  final VoidCallback onShowRoute;

  const PozoDetailsBottomSheet({
    super.key,
    required this.pozo,
    required this.onShowRoute,
  });

  @override
  State<PozoDetailsBottomSheet> createState() =>
      _PozoDetailsBottomSheetState();
}

class _PozoDetailsBottomSheetState extends State<PozoDetailsBottomSheet> {
  bool isLoading = true;
  String? error;
  PozoDetailsModel? details;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final service = PozoDetailsService();
      final data = await service.getMeasurementByPozoId(widget.pozo.codigo);
      if (!mounted) return;

      setState(() {
        details = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error al cargar los detalles';
        isLoading = false;
      });
    }
  }

  Color _getCloroColor(double cloro) {
    if (cloro < 0.2) return Colors.blue;
    if (cloro <= 2.0) return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final pozo = widget.pozo;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pozo.nombre,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${pozo.ciudad}, ${pozo.provincia} - ${pozo.parroquia}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 12),

            LoadingOverlay(
              isLoading: isLoading,
              message: 'Cargando detalles...',
              style: LoadingStyle.waterRipple,
              backgroundColor: Colors.white,
              isBlurEnabled: false,
              child: Builder(
                builder: (_) {
                  if (details != null) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _getCloroColor(details!.cloroResidual)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 24,
                            color: _getCloroColor(details!.cloroResidual),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cloro residual: ${details!.cloroResidual.toStringAsFixed(2)} ppm',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _getCloroColor(
                                      details!.cloroResidual,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Medido el: ${details!.fechaRegistro.toLocal().toString().substring(0, 19)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (error != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    Navigator.pop(context); 
                    widget.onShowRoute();
                  },
                  icon: const Icon(LucideIcons.map, size: 16, color: Colors.white),
                  label: const Text('Ver Ruta', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/home/pozo/${pozo.codigo}');
                  },
                  icon: const Icon(LucideIcons.arrowRight, size: 16, color: Colors.white),
                  label: const Text('Ver más', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
