import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation.dart';
import '../models/place.dart';
import '../models/group.dart';

class StorageService {
  static const String _historyKey = 'history';
  static const String _placesKey = 'places';
  static const String _groupsKey = 'groups';
  static const String _currencyKey = 'currency';
  static const String _defaultTipKey = 'defaultTip';

  // ---------- History ----------
  static Future<List<Calculation>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw.map((s) => Calculation.fromJson(jsonDecode(s))).toList().reversed.toList();
  }

  static Future<void> addToHistory(Calculation calc) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    raw.add(jsonEncode(calc.toJson()));
    if (raw.length > 200) raw.removeAt(0);
    await prefs.setStringList(_historyKey, raw);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  static Future<void> deleteCalculation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    raw.removeWhere((s) => jsonDecode(s)['id'] == id);
    await prefs.setStringList(_historyKey, raw);
  }

  // ---------- Places ----------
  static Future<List<Place>> getPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_placesKey) ?? [];
    return raw.map((s) => Place.fromJson(jsonDecode(s))).toList();
  }

  static Future<void> addPlace(Place place) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_placesKey) ?? [];
    raw.add(jsonEncode(place.toJson()));
    await prefs.setStringList(_placesKey, raw);
  }

  static Future<void> deletePlace(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_placesKey) ?? [];
    raw.removeWhere((s) => jsonDecode(s)['id'] == id);
    await prefs.setStringList(_placesKey, raw);
  }

  // ---------- Groups ----------
  static Future<List<Group>> getGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_groupsKey) ?? [];
    return raw.map((s) => Group.fromJson(jsonDecode(s))).toList();
  }

  static Future<void> addGroup(Group group) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_groupsKey) ?? [];
    raw.add(jsonEncode(group.toJson()));
    await prefs.setStringList(_groupsKey, raw);
  }

  static Future<void> deleteGroup(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_groupsKey) ?? [];
    raw.removeWhere((s) => jsonDecode(s)['id'] == id);
    await prefs.setStringList(_groupsKey, raw);
  }

  // ---------- Settings ----------
  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? '\$';
  }

  static Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  static Future<double> getDefaultTip() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_defaultTipKey) ?? 15.0;
  }

  static Future<void> setDefaultTip(double tip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_defaultTipKey, tip);
  }
}