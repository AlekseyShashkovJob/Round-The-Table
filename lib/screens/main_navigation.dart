import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'places_screen.dart';
import 'groups_screen.dart';
import 'stats_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const HistoryScreen();
      case 2:
        return const PlacesScreen();
      case 3:
        return const GroupsScreen();
      case 4:
        return const StatsScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(_index),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.surfaceColor, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.calculate_outlined), label: 'Calc'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined), label: 'History'),
            BottomNavigationBarItem(
                icon: Icon(Icons.place_outlined), label: 'Places'),
            BottomNavigationBarItem(
                icon: Icon(Icons.groups_outlined), label: 'Groups'),
            BottomNavigationBarItem(
                icon: Icon(Icons.insights_outlined), label: 'Stats'),
          ],
        ),
      ),
    );
  }
}