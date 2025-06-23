// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:workmanager/workmanager.dart';
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// LatLng? targetLocation;
// LatLng? currentLocation;
//
// class LocationMonitorPage extends StatefulWidget {
//   const LocationMonitorPage({Key? key}) : super(key: key);
//
//   @override
//   State<LocationMonitorPage> createState() => _LocationMonitorPageState();
// }
//
// class _LocationMonitorPageState extends State<LocationMonitorPage> {
//   MapController mapController = MapController();
//   bool isTracking = false;
//   StreamSubscription<Position>? _positionStreamSubscription;
//   bool isLoadingLocation = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initNotification();
//     _requestPermissions();
//     _startLocationUpdates();
//   }
//
//   Future<void> _initNotification() async {
//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const settings = InitializationSettings(android: android);
//     await flutterLocalNotificationsPlugin.initialize(settings);
//   }
//
//   Future<void> _requestPermissions() async {
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please enable location services")),
//       );
//     }
//   }
//
//   void _startLocationUpdates() {
//     _positionStreamSubscription = Geolocator.getPositionStream(
//       locationSettings: LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 10,
//       ),
//     ).listen((Position position) {
//       setState(() {
//         currentLocation = LatLng(position.latitude, position.longitude);
//         if (!isTracking) {
//           mapController.move(currentLocation!, 16.0);
//         }
//       });
//       if (isTracking) {
//         _checkProximityAndNotify();
//       }
//     }, onError: (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error updating location: $e")),
//       );
//     });
//   }
//
//   Future<void> _showNotification() async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'proximity_channel',
//       'Proximity Alerts',
//       channelDescription: 'Notifications for proximity to target location',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails platformDetails =
//     NotificationDetails(android: androidDetails);
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       'Target Acquired',
//       'You are within 100 meters of the objective!',
//       platformDetails,
//     );
//   }
//
//   void _checkProximityAndNotify() {
//     if (currentLocation == null || targetLocation == null) return;
//     final distance = Geolocator.distanceBetween(
//       currentLocation!.latitude,
//       currentLocation!.longitude,
//       targetLocation!.latitude,
//       targetLocation!.longitude,
//     );
//     if (distance <= 100) {
//       _showNotification();
//     }
//   }
//
//   Future<void> _getMyLocation() async {
//     setState(() {
//       isLoadingLocation = true;
//     });
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         currentLocation = LatLng(position.latitude, position.longitude);
//         mapController.move(currentLocation!, 16.0);
//         isLoadingLocation = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoadingLocation = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error getting location: $e")),
//       );
//     }
//   }
//
//   void _startMonitoring() {
//     if (targetLocation == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please place a marker on the map to track")),
//       );
//       return;
//     }
//
//     setState(() {
//       isTracking = true;
//     });
//
//     Workmanager().cancelAll();
//     Workmanager().registerPeriodicTask(
//       "locationMonitorTask",
//       "checkProximity",
//       frequency: Duration(minutes: 15),
//       initialDelay: Duration(seconds: 10),
//     );
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Tracking objective initiated")),
//     );
//   }
//
//   double _calculateDistance() {
//     if (currentLocation == null || targetLocation == null) return 0.0;
//     return Geolocator.distanceBetween(
//       currentLocation!.latitude,
//       currentLocation!.longitude,
//       targetLocation!.latitude,
//       targetLocation!.longitude,
//     ) / 1000;
//   }
//
//   String _calculateEstimatedTime() {
//     if (currentLocation == null || targetLocation == null) return "N/A";
//     const double walkingSpeedKmph = 5.0;
//     final double distanceKm = _calculateDistance();
//     if (distanceKm == 0.0) return "At objective";
//     final double hours = distanceKm / walkingSpeedKmph;
//     final int minutes = (hours * 60).round();
//     if (minutes < 1) return "< 1 minute";
//     return "~$minutes minutes";
//   }
//
//   @override
//   void dispose() {
//     _positionStreamSubscription?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF121212),
//       appBar: AppBar(
//         title: Text(
//           "Mission Tracker",
//           style: TextStyle(
//             fontFamily: 'RobotoMono',
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF00E676),
//           ),
//         ),
//         backgroundColor: Color(0xFF1E1E1E),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Text(
//               isTracking
//                   ? "Tracking active. Move to objective."
//                   : "Tap map to set target or get current position.",
//               style: TextStyle(
//                 fontFamily: 'RobotoMono',
//                 color: Colors.white70,
//                 fontSize: 14,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.all(16.0),
//             height: 350,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Color(0xFF00E676), width: 2),
//               boxShadow: [
//                 BoxShadow(
//                   color: Color(0xFF00E676).withOpacity(0.3),
//                   spreadRadius: 2,
//                   blurRadius: 10,
//                   offset: Offset(0, 0),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: FlutterMap(
//                 mapController: mapController,
//                 options: MapOptions(
//                   initialCenter: LatLng(20.5937, 78.9629),
//                   initialZoom: 5.0,
//                   onTap: isTracking
//                       ? null
//                       : (tapPosition, point) {
//                     setState(() {
//                       targetLocation = point;
//                     });
//                   },
//                 ),
//                 children: [
//                   TileLayer(
//                     urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//                     userAgentPackageName: 'com.example.app',
//                     // backgroundColor: Color(0xFF1E1E1E),
//                   ),
//                   MarkerLayer(
//                     markers: [
//                       if (currentLocation != null)
//                         Marker(
//                           point: currentLocation!,
//                           width: 40,
//                           height: 40,
//                           child: AnimatedScale(
//                             duration: Duration(milliseconds: 1000),
//                             scale: 1.2,
//                             child: Icon(
//                               Icons.radar,
//                               color: Color(0xFF00E676),
//                               size: 40,
//                             ),
//                           ),
//                         ),
//                       if (targetLocation != null)
//                         Marker(
//                           point: targetLocation!,
//                           width: 40,
//                           height: 40,
//                           child: AnimatedScale(
//                             duration: Duration(milliseconds: 1000),
//                             scale: 1.2,
//                             child: Icon(
//                               Icons.gps_fixed,
//                               color: Colors.redAccent,
//                               size: 40,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Column(
//               children: [
//                 AnimatedContainer(
//                   duration: Duration(milliseconds: 300),
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF00E676),
//                       foregroundColor: Color(0xFF121212),
//                       minimumSize: Size(double.infinity, 56),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 5,
//                       shadowColor: Color(0xFF00E676).withOpacity(0.5),
//                     ),
//                     icon: isLoadingLocation
//                         ? SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(
//                         color: Color(0xFF121212),
//                         strokeWidth: 2,
//                       ),
//                     )
//                         : Icon(
//                       currentLocation != null
//                           ? Icons.directions_walk
//                           : Icons.location_searching,
//                       size: 24,
//                     ),
//                     label: Text(
//                       isLoadingLocation ? "Acquiring Position..." : "Get Position",
//                       style: TextStyle(
//                         fontFamily: 'RobotoMono',
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     onPressed: isLoadingLocation ? null : _getMyLocation,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 AnimatedContainer(
//                   duration: Duration(milliseconds: 300),
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                       isTracking ? Colors.redAccent : Color(0xFF00E676),
//                       foregroundColor: Color(0xFF121212),
//                       minimumSize: Size(double.infinity, 56),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 5,
//                       shadowColor: isTracking
//                           ? Colors.redAccent.withOpacity(0.5)
//                           : Color(0xFF00E676).withOpacity(0.5),
//                     ),
//                     icon: Icon(
//                       isTracking ? Icons.stop : Icons.track_changes,
//                       size: 24,
//                     ),
//                     label: Text(
//                       isTracking ? "Abort Mission" : "Initiate Tracking",
//                       style: TextStyle(
//                         fontFamily: 'RobotoMono',
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     onPressed: () {
//                       if (isTracking) {
//                         Workmanager().cancelAll();
//                         setState(() {
//                           isTracking = false;
//                         });
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text("Mission aborted")),
//                         );
//                       } else {
//                         _startMonitoring();
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.vertical,
//               physics: BouncingScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Card(
//                   color: Color(0xFF1E1E1E).withOpacity(0.9),
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     side: BorderSide(color: Color(0xFF00E676), width: 1),
//                   ),
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     physics: BouncingScrollPhysics(),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Mission Intel",
//                             style: TextStyle(
//                               fontFamily: 'RobotoMono',
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF00E676),
//                             ),
//                           ),
//                           SizedBox(height: 12),
//                           _buildDetailRow(
//                             "Agent Position",
//                             currentLocation == null
//                                 ? "Not acquired"
//                                 : "Lat: ${currentLocation!.latitude.toStringAsFixed(4)}, Lng: ${currentLocation!.longitude.toStringAsFixed(4)}",
//                           ),
//                           _buildDetailRow(
//                             "Objective",
//                             targetLocation == null
//                                 ? "Not set"
//                                 : "Lat: ${targetLocation!.latitude.toStringAsFixed(4)}, Lng: ${targetLocation!.longitude.toStringAsFixed(4)}",
//                           ),
//                           _buildDetailRow(
//                             "Distance",
//                             currentLocation == null || targetLocation == null
//                                 ? "N/A"
//                                 : "${_calculateDistance().toStringAsFixed(2)} km",
//                           ),
//                           _buildDetailRow(
//                             "ETA (Foot)",
//                             _calculateEstimatedTime(),
//                           ),
//                           _buildDetailRow(
//                             "Environment",
//                             "N/A (Requires sensor data)",
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           SizedBox(
//             width: 150,
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontFamily: 'RobotoMono',
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.white70,
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 200,
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontFamily: 'RobotoMono',
//                 fontSize: 16,
//                 color: Color(0xFF00E676),
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class AnimatedScale extends StatefulWidget {
//   final Widget child;
//   final Duration duration;
//   final double scale;
//
//   const AnimatedScale({
//     Key? key,
//     required this.child,
//     required this.duration,
//     required this.scale,
//   }) : super(key: key);
//
//   @override
//   _AnimatedScaleState createState() => _AnimatedScaleState();
// }
//
// class _AnimatedScaleState extends State<AnimatedScale>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: widget.duration,
//       vsync: this,
//     )..repeat(reverse: true);
//     _animation = Tween<double>(begin: 1.0, end: widget.scale).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ScaleTransition(
//       scale: _animation,
//       child: widget.child,
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

LatLng? targetLocation;
LatLng? currentLocation;

class LocationMonitorPage extends StatefulWidget {
  const LocationMonitorPage({Key? key}) : super(key: key);

  @override
  State<LocationMonitorPage> createState() => _LocationMonitorPageState();
}

class _LocationMonitorPageState extends State<LocationMonitorPage> {
  MapController mapController = MapController();
  bool isTracking = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool isLoadingLocation = false;
  String _notificationTitle = 'Target Acquired'; // Default notification title
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initNotification();
    _requestPermissions();
    _startLocationUpdates();
    _titleController.text = _notificationTitle; // Initialize TextField with default title
  }

  Future<void> _initNotification() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> _requestPermissions() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enable location services")),
      );
    }
  }

  void _startLocationUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        if (!isTracking) {
          mapController.move(currentLocation!, 16.0);
        }
      });
      if (isTracking) {
        _checkProximityAndNotify();
      }
    }, onError: (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating location: $e")),
      );
    });
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'proximity_channel',
      'Proximity Alerts',
      channelDescription: 'Notifications for proximity to target location',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      _notificationTitle, // Use custom title
      'You are within 100 meters of the objective!',
      platformDetails,
    );
  }

  void _checkProximityAndNotify() {
    if (currentLocation == null || targetLocation == null) return;
    final distance = Geolocator.distanceBetween(
      currentLocation!.latitude,
      currentLocation!.longitude,
      targetLocation!.latitude,
      targetLocation!.longitude,
    );
    if (distance <= 100) {
      _showNotification();
    }
  }

  Future<void> _getMyLocation() async {
    setState(() {
      isLoadingLocation = true;
    });
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        mapController.move(currentLocation!, 16.0);
        isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }

  void _startMonitoring() {
    if (targetLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please place a marker on the map to track")),
      );
      return;
    }

    setState(() {
      isTracking = true;
      _notificationTitle = _titleController.text.isEmpty
          ? 'Target Acquired'
          : _titleController.text; // Update notification title
    });

    Workmanager().cancelAll();
    Workmanager().registerPeriodicTask(
      "locationMonitorTask",
      "checkProximity",
      frequency: Duration(minutes: 15),
      initialDelay: Duration(seconds: 10),
      inputData: {
        'title': _notificationTitle, // Pass custom title to Workmanager
        'targetLat': targetLocation!.latitude,
        'targetLng': targetLocation!.longitude,
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tracking objective initiated")),
    );
  }

  double _calculateDistance() {
    if (currentLocation == null || targetLocation == null) return 0.0;
    return Geolocator.distanceBetween(
      currentLocation!.latitude,
      currentLocation!.longitude,
      targetLocation!.latitude,
      targetLocation!.longitude,
    ) / 1000;
  }

  String _calculateEstimatedTime() {
    if (currentLocation == null || targetLocation == null) return "N/A";
    const double walkingSpeedKmph = 5.0;
    final double distanceKm = _calculateDistance();
    if (distanceKm == 0.0) return "At objective";
    final double hours = distanceKm / walkingSpeedKmph;
    final int minutes = (hours * 60).round();
    if (minutes < 1) return "< 1 minute";
    return "~$minutes minutes";
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          "Mission Tracker",
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
            color: Color(0xFF00E676),
          ),
        ),
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _titleController,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                color: Color(0xFF00E676),
              ),
              decoration: InputDecoration(
                labelText: 'Notification Title',
                labelStyle: TextStyle(
                  fontFamily: 'RobotoMono',
                  color: Colors.white70,
                ),
                hintText: 'Enter custom notification title',
                hintStyle: TextStyle(
                  fontFamily: 'RobotoMono',
                  color: Colors.white38,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00E676), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00E676), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Color(0xFF1E1E1E).withOpacity(0.9),
              ),
              onChanged: (value) {
                setState(() {
                  _notificationTitle = value.isEmpty ? 'Target Acquired' : value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              isTracking
                  ? "Tracking active. Move to objective."
                  : "Tap map to set target or get current position.",
              style: TextStyle(
                fontFamily: 'RobotoMono',
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: EdgeInsets.all(16.0),
            height: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF00E676), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00E676).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: LatLng(20.5937, 78.9629),
                  initialZoom: 5.0,
                  onTap: isTracking
                      ? null
                      : (tapPosition, point) {
                    setState(() {
                      targetLocation = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      if (currentLocation != null)
                        Marker(
                          point: currentLocation!,
                          width: 40,
                          height: 40,
                          child: AnimatedScale(
                            duration: Duration(milliseconds: 1000),
                            scale: 1.2,
                            child: Icon(
                              Icons.radar,
                              color: Color(0xFF00E676),
                              size: 40,
                            ),
                          ),
                        ),
                      if (targetLocation != null)
                        Marker(
                          point: targetLocation!,
                          width: 40,
                          height: 40,
                          child: AnimatedScale(
                            duration: Duration(milliseconds: 1000),
                            scale: 1.2,
                            child: Icon(
                              Icons.gps_fixed,
                              color: Colors.redAccent,
                              size: 40,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00E676),
                      foregroundColor: Color(0xFF121212),
                      minimumSize: Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Color(0xFF00E676).withOpacity(0.5),
                    ),
                    icon: isLoadingLocation
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFF121212),
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(
                      currentLocation != null
                          ? Icons.directions_walk
                          : Icons.location_searching,
                      size: 24,
                    ),
                    label: Text(
                      isLoadingLocation ? "Acquiring Position..." : "Get Position",
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: isLoadingLocation ? null : _getMyLocation,
                  ),
                ),
                SizedBox(height: 12),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isTracking ? Colors.redAccent : Color(0xFF00E676),
                      foregroundColor: Color(0xFF121212),
                      minimumSize: Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: isTracking
                          ? Colors.redAccent.withOpacity(0.5)
                          : Color(0xFF00E676).withOpacity(0.5),
                    ),
                    icon: Icon(
                      isTracking ? Icons.stop : Icons.track_changes,
                      size: 24,
                    ),
                    label: Text(
                      isTracking ? "Abort Mission" : "Initiate Tracking",
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      if (isTracking) {
                        Workmanager().cancelAll();
                        setState(() {
                          isTracking = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Mission aborted")),
                        );
                      } else {
                        _startMonitoring();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Color(0xFF1E1E1E).withOpacity(0.9),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Color(0xFF00E676), width: 1),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mission Intel",
                            style: TextStyle(
                              fontFamily: 'RobotoMono',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00E676),
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildDetailRow(
                            "Agent Position",
                            currentLocation == null
                                ? "Not acquired"
                                : "Lat: ${currentLocation!.latitude.toStringAsFixed(4)}, Lng: ${currentLocation!.longitude.toStringAsFixed(4)}",
                          ),
                          _buildDetailRow(
                            "Objective",
                            targetLocation == null
                                ? "Not set"
                                : "Lat: ${targetLocation!.latitude.toStringAsFixed(4)}, Lng: ${targetLocation!.longitude.toStringAsFixed(4)}",
                          ),
                          _buildDetailRow(
                            "Distance",
                            currentLocation == null || targetLocation == null
                                ? "N/A"
                                : "${_calculateDistance().toStringAsFixed(2)} km",
                          ),
                          _buildDetailRow(
                            "ETA (Foot)",
                            _calculateEstimatedTime(),
                          ),
                          _buildDetailRow(
                            "Environment",
                            "N/A (Requires sensor data)",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 16,
                color: Color(0xFF00E676),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedScale extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scale;

  const AnimatedScale({
    Key? key,
    required this.child,
    required this.duration,
    required this.scale,
  }) : super(key: key);

  @override
  _AnimatedScaleState createState() => _AnimatedScaleState();
}

class _AnimatedScaleState extends State<AnimatedScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}