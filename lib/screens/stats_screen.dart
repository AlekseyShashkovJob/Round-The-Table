import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calculation.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Calculation> _all = [];
  String _currency = '\$';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final h = await StorageService.getHistory();
    final c = await StorageService.getCurrency();
    setState(() {
      _all = h;
      _currency = c;
    });
  }

  Map<String, double> _lastMonthsBills() {
    final map = <String, double>{};
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i);
      map[DateFormat('MMM').format(d)] = 0;
    }
    for (final c in _all) {
      final key = DateFormat('MMM').format(c.date);
      if (map.containsKey(key)) {
        map[key] = (map[key] ?? 0) + c.totalWithTip;
      }
    }
    return map;
  }

  Map<String, double> _tipDistribution() {
    final map = <String, double>{'0-10%': 0, '10-15%': 0, '15-20%': 0, '20%+': 0};
    for (final c in _all) {
      if (c.tipPercent < 10) {
        map['0-10%'] = map['0-10%']! + 1;
      } else if (c.tipPercent < 15) {
        map['10-15%'] = map['10-15%']! + 1;
      } else if (c.tipPercent < 20) {
        map['15-20%'] = map['15-20%']! + 1;
      } else {
        map['20%+'] = map['20%+']! + 1;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent = _all.fold<double>(0, (s, c) => s + c.totalWithTip);
    final totalTips = _all.fold<double>(0, (s, c) => s + c.tipAmount);
    final avgTip = _all.isEmpty ? 0.0 : _all.fold<double>(0, (s, c) => s + c.tipPercent) / _all.length;
    final avgBill = _all.isEmpty ? 0.0 : totalSpent / _all.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        automaticallyImplyLeading: false,
      ),
      body: _all.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insights_outlined, size: 80, color: AppTheme.textSecondary),
                  SizedBox(height: 16),
                  Text('No data to display',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
            : ScrollConfiguration(
                  behavior: const _NoStretchScrollBehavior(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const ClampingScrollPhysics(),
                    children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text('Total Spent',
                          style: TextStyle(color: Colors.black87, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text('$_currency${totalSpent.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 36,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${_all.length} calculations',
                          style: const TextStyle(color: Colors.black87, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _statCard('Total Tips', '$_currency${totalTips.toStringAsFixed(0)}')),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Avg Bill', '$_currency${avgBill.toStringAsFixed(0)}')),
                  ],
                ),
                const SizedBox(height: 12),
                _statCard('Average Tip %', '${avgTip.toStringAsFixed(1)}%', full: true),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Last 6 Months',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: BarChartWidget(
                          data: _lastMonthsBills(),
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tip Distribution',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: PieChartWidget(data: _tipDistribution()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            )
    );
  }

  Widget _statCard(String label, String value, {bool full = false}) => Container(
        padding: const EdgeInsets.all(16),
        width: full ? double.infinity : null,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}

class _NoStretchScrollBehavior extends ScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // Отключаем растягивающий эффект
  }
}