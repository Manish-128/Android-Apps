import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OSMFlutterMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OSM Flutter Example')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(20.5937, 78.9629), // Center on India
          initialZoom: 5.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.your_app',
          ),
        ],
      ),
    );
  }
}