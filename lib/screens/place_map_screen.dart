import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/place.dart';
import '../theme/app_theme.dart';

class PlaceMapScreen extends StatelessWidget {
  final Place place;
  const PlaceMapScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(place.latitude, place.longitude);
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.roundthetable.app',
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: point,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.location_on,
                        color: AppTheme.primaryColor, size: 50),
                  ),
                ]),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppTheme.cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (place.address.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(place.address,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                ],
                const SizedBox(height: 6),
                Text(
                  '${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}