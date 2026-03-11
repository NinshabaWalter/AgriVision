import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PriceTrendChart extends StatelessWidget {
  final String cropType;
  final String location;
  final List<double>? data; // Optional override for data

  const PriceTrendChart({
    super.key,
    required this.cropType,
    required this.location,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    final prices = data ?? List.generate(30, (i) => 40 + (i * 0.6) + (i % 4 * 1.8));
    return LineChart(
      LineChartData(
        minY: (prices.reduce((a, b) => a < b ? a : b) - 5).floorToDouble(),
        maxY: (prices.reduce((a, b) => a > b ? a : b) + 5).ceilToDouble(),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 7, getTitlesWidget: (v, meta) {
              final day = v.toInt();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('D${day + 1}', style: const TextStyle(fontSize: 10)),
              );
            }),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            spots: [
              for (int i = 0; i < prices.length; i++) FlSpot(i.toDouble(), prices[i]),
            ],
          ),
        ],
      ),
    );
  }
}