import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calculation.dart';
import '../models/group.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bar_chart_widget.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  List<Calculation> _calcs = [];
  String _currency = '\$';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await StorageService.getHistory();
    final currency = await StorageService.getCurrency();
    setState(() {
      _calcs = history.where((c) => c.groupId == widget.group.id).toList();
      _currency = currency;
    });
  }

  Map<String, double> _monthlyBills() {
    final map = <String, double>{};
    for (final c in _calcs) {
      final key = DateFormat('MMM').format(c.date);
      map[key] = (map[key] ?? 0) + c.billAmount;
    }
    return map;
  }

  Map<String, double> _monthlyTips() {
    final map = <String, double>{};
    for (final c in _calcs) {
      final key = DateFormat('MMM').format(c.date);
      map[key] = (map[key] ?? 0) + c.tipAmount;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final totalBill = _calcs.fold<double>(0, (s, c) => s + c.billAmount);
    final totalTip = _calcs.fold<double>(0, (s, c) => s + c.tipAmount);
    final avgTipPercent = _calcs.isEmpty
        ? 0.0
        : _calcs.fold<double>(0, (s, c) => s + c.tipPercent) / _calcs.length;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.group.emoji} ${widget.group.name}')),
      body: _calcs.isEmpty
          ? const Center(
              child: Text('No entries for this group yet',
                  style: TextStyle(color: AppTheme.textSecondary)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(child: _statCard('Total Spent', '$_currency${totalBill.toStringAsFixed(0)}')),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Total Tips', '$_currency${totalTip.toStringAsFixed(0)}')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _statCard('Entries', '${_calcs.length}')),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Avg Tip', '${avgTipPercent.toStringAsFixed(1)}%')),
                  ],
                ),
                const SizedBox(height: 20),
                if (_monthlyBills().isNotEmpty)
                  _chartCard('Bills by Month', _monthlyBills(), AppTheme.primaryColor),
                const SizedBox(height: 16),
                if (_monthlyTips().values.any((v) => v > 0))
                  _chartCard('Tips by Month', _monthlyTips(), AppTheme.successColor),
                const SizedBox(height: 20),
                const Text('Recent Entries',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._calcs.take(10).map(_entryTile),
              ],
            ),
    );
  }

  Widget _statCard(String label, String value) => Container(
        padding: const EdgeInsets.all(16),
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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _chartCard(String title, Map<String, double> data, Color color) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(height: 180, child: BarChartWidget(data: data, color: color)),
          ],
        ),
      );

  Widget _entryTile(Calculation c) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$_currency${c.totalWithTip.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(DateFormat('MMM d, yyyy').format(c.date),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Tip $_currency${c.tipAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: 13)),
                Text('${c.peopleCount} ppl',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      );
}