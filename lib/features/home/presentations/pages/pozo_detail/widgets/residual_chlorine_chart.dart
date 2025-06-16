import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saviaqua/features/home/model/pozo_details/pozo_details_model.dart';

class ResidualChlorineChart extends StatelessWidget {
  final List<PozoDetailsModel> historial;

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

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY - 1,
          maxY: maxY + 1,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                interval: (maxX - minX) / 3,
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Text(DateFormat.Hm().format(date), style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: ((maxY - minY) / 4).clamp(0.1, 10),
                getTitlesWidget: (value, _) => Text('${value.toStringAsFixed(1)} ppm', style: const TextStyle(fontSize: 10)),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.teal,
              barWidth: 2,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.15)),
            ),
          ],
        ),
      ),
    );
  }
}
