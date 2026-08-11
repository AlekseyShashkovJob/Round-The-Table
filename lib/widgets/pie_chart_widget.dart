import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;

  const PieChartWidget({super.key, required this.data});

  static const _colors = [
    AppTheme.primaryColor,
    AppTheme.successColor,
    Color(0xFF64B5F6),
    Color(0xFFEF5350),
  ];

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<double>(0, (s, v) => s + v);
    if (total <= 0) {
      return const Center(
        child: Text('No data', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    final entries = data.entries.where((e) => e.value > 0).toList();
    if (entries.isEmpty) {
      return const Center(
        child: Text('No data', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              // Отключаем touch — чтобы не мешать скроллу
              pieTouchData: PieTouchData(enabled: false),
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              sections: List.generate(entries.length, (i) {
                final v = entries[i].value;
                final percent = v / total * 100;
                return PieChartSectionData(
                  value: v,
                  color: _colors[i % _colors.length],
                  title: percent < 8 ? '' : '${percent.toStringAsFixed(0)}%',
                  radius: 55,
                  titleStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(entries.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _colors[i % _colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entries[i].key} (${entries[i].value.toInt()})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}