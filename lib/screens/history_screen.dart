import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calculation.dart';
import '../models/place.dart';
import '../models/group.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Calculation> _history = [];
  Map<String, Place> _placesMap = {};
  Map<String, Group> _groupsMap = {};
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
    final history = await StorageService.getHistory();
    final currency = await StorageService.getCurrency();
    final places = await StorageService.getPlaces();
    final groups = await StorageService.getGroups();
    setState(() {
      _history = history;
      _currency = currency;
      _placesMap = {for (final p in places) p.id: p};
      _groupsMap = {for (final g in groups) g.id: g};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        automaticallyImplyLeading: false,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: _history.isEmpty
          ? _empty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final calc = _history[index];
                final place = calc.placeId != null ? _placesMap[calc.placeId] : null;
                final group = calc.groupId != null ? _groupsMap[calc.groupId] : null;
                return Dismissible(
                  key: Key(calc.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await StorageService.deleteCalculation(calc.id);
                    _load();
                  },
                  child: _card(calc, place, group),
                );
              },
            ),
    );
  }

  Widget _card(Calculation calc, Place? place, Group? group) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$_currency${calc.totalWithTip.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(DateFormat('MMM d, HH:mm').format(calc.date),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Bill $_currency${calc.billAmount.toStringAsFixed(2)}  •  '
              'Tip ${calc.tipPercent.toStringAsFixed(0)}%  •  '
              '${calc.peopleCount} ppl',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text('$_currency${calc.perPerson.toStringAsFixed(2)} per person',
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
            if (place != null || group != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  if (place != null) _chip(Icons.place, place.name),
                  if (group != null) _chip(null, '${group.emoji} ${group.name}'),
                ],
              ),
            ],
          ],
        ),
      );

  Widget _chip(IconData? icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppTheme.primaryColor),
              const SizedBox(width: 4),
            ],
            Text(text, style: const TextStyle(fontSize: 12)),
          ],
        ),
      );

  Widget _empty() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text('No calculations yet',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
          ],
        ),
      );

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await StorageService.clearHistory();
              _load();
            },
            child: const Text('Clear', style: TextStyle(color: AppTheme.dangerColor)),
          ),
        ],
      ),
    );
  }
}