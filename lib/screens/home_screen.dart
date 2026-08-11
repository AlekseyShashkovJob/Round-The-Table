import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/calculation.dart';
import '../models/place.dart';
import '../models/group.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _billController = TextEditingController();
  double _tipPercent = 15.0;
  int _peopleCount = 2;
  String _currency = '\$';
  Place? _selectedPlace;
  Group? _selectedGroup;
  List<Place> _places = [];
  List<Group> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    final tip = await StorageService.getDefaultTip();
    final currency = await StorageService.getCurrency();
    final places = await StorageService.getPlaces();
    final groups = await StorageService.getGroups();
    setState(() {
      _tipPercent = tip;
      _currency = currency;
      _places = places;
      _groups = groups;
    });
  }

  void _calculate() {
    final bill = double.tryParse(_billController.text) ?? 0;
    if (bill <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid bill amount')),
      );
      return;
    }

    final tipAmount = bill * _tipPercent / 100;
    final total = bill + tipAmount;
    final perPerson = total / _peopleCount;

    final calc = Calculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      billAmount: bill,
      tipPercent: _tipPercent,
      peopleCount: _peopleCount,
      totalWithTip: total,
      perPerson: perPerson,
      date: DateTime.now(),
      placeId: _selectedPlace?.id,
      groupId: _selectedGroup?.id,
    );

    StorageService.addToHistory(calc);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          calculation: calc,
          currency: _currency,
          place: _selectedPlace,
          group: _selectedGroup,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Round The Table'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              _loadDefaults();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Bill Amount'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    _currency,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _billController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: AppTheme.textSecondary),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('Tip'),
                Text(
                  '${_tipPercent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppTheme.primaryColor,
                inactiveTrackColor: AppTheme.surfaceColor,
                thumbColor: AppTheme.primaryColor,
                overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _tipPercent,
                min: 0,
                max: 30,
                divisions: 30,
                onChanged: (v) => setState(() => _tipPercent = v),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [10, 15, 18, 20, 25].map((p) => _quickTipButton(p.toDouble())).toList(),
            ),
            const SizedBox(height: 24),
            _label('Split Between'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _counterBtn(Icons.remove, _peopleCount > 1
                      ? () => setState(() => _peopleCount--) : null),
                  Column(
                    children: [
                      Text(
                        '$_peopleCount',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _peopleCount == 1 ? 'person' : 'people',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  _counterBtn(Icons.add, () => setState(() => _peopleCount++)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _label('Place (optional)'),
            const SizedBox(height: 8),
            _dropdownCard(
              icon: Icons.place_outlined,
              text: _selectedPlace?.name ?? 'Select place',
              onTap: _pickPlace,
              onClear: _selectedPlace != null ? () => setState(() => _selectedPlace = null) : null,
            ),
            const SizedBox(height: 12),
            _label('Group (optional)'),
            const SizedBox(height: 8),
            _dropdownCard(
              icon: Icons.groups_outlined,
              text: _selectedGroup != null
                  ? '${_selectedGroup!.emoji} ${_selectedGroup!.name}'
                  : 'Select group',
              onTap: _pickGroup,
              onClear: _selectedGroup != null ? () => setState(() => _selectedGroup = null) : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculate,
                child: const Text('Calculate'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(
        t,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _counterBtn(IconData icon, VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: onTap != null ? AppTheme.primaryColor : AppTheme.surfaceColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: onTap != null ? Colors.black : AppTheme.textSecondary),
        ),
      );

  Widget _quickTipButton(double percent) {
    final selected = _tipPercent == percent;
    return GestureDetector(
      onTap: () => setState(() => _tipPercent = percent),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${percent.toStringAsFixed(0)}%',
          style: TextStyle(
            color: selected ? Colors.black : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _dropdownCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
              )
            else
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPlace() async {
    if (_places.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add places in the "Places" tab first')),
      );
      return;
    }
    final result = await showModalBottomSheet<Place>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _pickerSheet(
        title: 'Select Place',
        items: _places.map((p) => _PickerItem(
          title: p.name,
          subtitle: p.address,
          icon: Icons.place,
          value: p,
        )).toList(),
      ),
    );
    if (result != null) setState(() => _selectedPlace = result);
  }

  Future<void> _pickGroup() async {
    if (_groups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add groups in the "Groups" tab first')),
      );
      return;
    }
    final result = await showModalBottomSheet<Group>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _pickerSheet(
        title: 'Select Group',
        items: _groups.map((g) => _PickerItem(
          title: '${g.emoji} ${g.name}',
          subtitle: null,
          icon: Icons.groups,
          value: g,
        )).toList(),
      ),
    );
    if (result != null) setState(() => _selectedGroup = result);
  }

  Widget _pickerSheet({required String title, required List<_PickerItem> items}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...items.map((it) => ListTile(
                  onTap: () => Navigator.pop(context, it.value),
                  leading: Icon(it.icon, color: AppTheme.primaryColor),
                  title: Text(it.title),
                  subtitle: it.subtitle != null ? Text(it.subtitle!) : null,
                )),
          ],
        ),
      ),
    );
  }
}

class _PickerItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final dynamic value;
  _PickerItem({required this.title, this.subtitle, required this.icon, required this.value});
}