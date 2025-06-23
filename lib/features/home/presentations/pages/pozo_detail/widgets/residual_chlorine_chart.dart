import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saviaqua/features/home/model/pozo_details/pozo_details_model.dart';

class ResidualChlorineChart extends StatelessWidget {
  final List<PozoDetailsModel> historial;
  final bool isFullscreen;
  final double umbral = 33.0;

  const ResidualChlorineChart({
    super.key,
    required this.historial,
    this.isFullscreen = false,
  });

  @override
  Widget build(BuildContext context) {
    if (historial.isEmpty) {
      return const Center(child: Text('Sin datos para mostrar el gráfico.'));
    }

    final spots =
        historial.map((medicion) {
            final x = medicion.fechaRegistro.millisecondsSinceEpoch.toDouble();
            final y = medicion.cloroResidual;
            return FlSpot(x, y);
          }).toList()
          ..sort((a, b) => a.x.compareTo(b.x));

    final minX = spots.first.x;
    final maxX = spots.last.x;
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final bufferY = 1.5;

    final puntosColores =
        spots.map((spot) {
          if (spot.y > umbral) {
            return Colors.red;
          } else if (spot.y > umbral / 2) {
            return Colors.green;
          } else {
            return Colors.blue;
          }
        }).toList();

    final chartWidth =
        spots.length < 6
            ? MediaQuery.of(context).size.width
            : spots.length * 50;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isFullscreen)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.blue),
                  tooltip: 'Ver gráfico horizontal',
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.white,
                      builder:
                          (_) => Dialog(
                            insetPadding: EdgeInsets.zero,
                            child: Scaffold(
                              appBar: AppBar(
                                backgroundColor: Colors.white,
                                title: Text(
                                  'Gráfico Horizontal',
                                  style: const TextStyle(color: Colors.blue),
                                ),
                                iconTheme: const IconThemeData(
                                  color: Colors.blue,
                                ),
                              ),
                              body: SafeArea(
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: ResidualChlorineChart(
                                    historial: historial,
                                    isFullscreen: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    );
                  },
                ),
              ),
            SizedBox(
              height: 340,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: chartWidth.toDouble(),
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
                          tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                spot.x.toInt(),
                              );
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
                              FlLine(
                                color: color.withOpacity(0.6),
                                strokeWidth: 2,
                              ),
                              FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (maxX - minX) / 3,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt(),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  DateFormat('dd MMM').format(date),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: ((maxY - minY) / 4).clamp(0.1, 10),
                            reservedSize: 35,
                            getTitlesWidget:
                                (value, _) => Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Text(
                                    '${value.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: ((maxY - minY) / 4).clamp(0.1, 10),
                        getDrawingHorizontalLine:
                            (value) => FlLine(
                              color: Colors.grey.shade300,
                              strokeWidth: 1,
                            ),
                        getDrawingVerticalLine:
                            (value) => FlLine(
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
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: umbral,
                            color: Colors.redAccent,
                            strokeWidth: 1.5,
                            dashArray: [5, 5],
                            label: HorizontalLineLabel(
                              show: true,
                              alignment: Alignment.topRight,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              labelResolver: (_) => 'Umbral: $umbral ppm',
                            ),
                          ),
                        ],
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
          ],
        ),
      ),
    );
  }
}
