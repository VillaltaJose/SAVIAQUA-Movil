import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saviaqua/features/home/model/pozo_details/pozo_details_model.dart';

class ResidualChlorineChart extends StatelessWidget {
  final List<PozoDetailsModel> historial;
  final double umbral = 33.0;

  const ResidualChlorineChart({super.key, required this.historial});

  @override
  Widget build(BuildContext context) {
    if (historial.isEmpty) {
      return const Center(child: Text('Sin datos para mostrar el gráfico.'));
    }

    final spots = historial.map((medicion) {
      final x = medicion.fechaRegistro.millisecondsSinceEpoch.toDouble();
      final y = medicion.m1;
      return FlSpot(x, y);
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final minX = spots.first.x;
    final maxX = spots.last.x;
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    List<Color> puntosColores = spots.map((spot) {
      if (spot.y > umbral) {
        return Colors.red;
      } else if (spot.y > umbral / 2) {
        return Colors.green;
      } else {
        return Colors.blue;
      }
    }).toList();

    final bufferY = 1.5;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: SizedBox(
        height: 340,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: spots.length * 50,
            child: LineChart(
              LineChartData(
                clipData: FlClipData.all(),
                minX: minX,
                maxX: maxX,
                minY: (minY - 1).clamp(0, double.infinity),
                maxY: maxY + bufferY,
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                        return LineTooltipItem(
                          '${DateFormat('dd MMM yyyy HH:mm').format(date)}\n${spot.y.toStringAsFixed(2)} ppm',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((index) {
                      final color = puntosColores[index];
                      return TouchedSpotIndicatorData(
                        FlLine(color: color.withOpacity(0.6), strokeWidth: 2),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                                radius: 8,
                                color: color,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                        ),
                      );
                    }).toList();
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    axisNameSize: 30,
                    axisNameWidget: const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Fecha',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxX - minX) / 3,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('dd MMM').format(date),
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameSize: 40,
                    axisNameWidget: const Padding(
                      padding: EdgeInsets.only(bottom: 0.0),
                      child: Text(
                        'Cloro Residual (ppm)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: ((maxY - minY) / 4).clamp(0.1, 10),
                      reservedSize: 35,
                      getTitlesWidget: (value, _) => Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Text(
                          '${value.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: ((maxY - minY) / 4).clamp(0.1, 10),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.black54),
                    bottom: BorderSide(color: Colors.black54),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final color = puntosColores[index];
                        return FlDotCirclePainter(
                          radius: 5,
                          color: color,
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}