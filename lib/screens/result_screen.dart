import 'package:flutter/material.dart';
import '../models/calculation.dart';
import '../models/place.dart';
import '../models/group.dart';
import '../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final Calculation calculation;
  final String currency;
  final Place? place;
  final Group? group;

  const ResultScreen({
    super.key,
    required this.calculation,
    required this.currency,
    this.place,
    this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  const Text(
                    'Each Person Pays',
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currency${calculation.perPerson.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${calculation.peopleCount} ${calculation.peopleCount == 1 ? "person" : "people"}',
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _row('Bill Amount', '$currency${calculation.billAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  _row('Tip (${calculation.tipPercent.toStringAsFixed(0)}%)',
                      '$currency${calculation.tipAmount.toStringAsFixed(2)}'),
                  const Divider(height: 30, color: AppTheme.surfaceColor),
                  _row('Total', '$currency${calculation.totalWithTip.toStringAsFixed(2)}', bold: true),
                  if (place != null) ...[
                    const SizedBox(height: 16),
                    _iconRow(Icons.place, place!.name),
                  ],
                  if (group != null) ...[
                    const SizedBox(height: 10),
                    _iconRow(Icons.groups, '${group!.emoji} ${group!.name}'),
                  ],
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: bold ? 17 : 14,
                color: bold ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                fontSize: bold ? 20 : 16,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: bold ? AppTheme.primaryColor : AppTheme.textPrimary,
              )),
        ],
      );

  Widget _iconRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      );
}