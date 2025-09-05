import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // still needed for GoogleMap
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'report_screen.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final TextEditingController destinationController = TextEditingController();

  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
      _markers.add(
        Marker(
          markerId: const MarkerId("currentLocation"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: "You are here"),
        ),
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
  }

  Future<void> _getRoute(String destination) async {
    if (_currentPosition == null || destination.isEmpty) return;

    final origin =
        "${_currentPosition!.latitude},${_currentPosition!.longitude}";

    final geocodeUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?address=$destination&key=AIzaSyAX2a-xMEQ2VB_oPdtoD5o8IZLeCUWYTqU";
    final geoResponse = await http.get(Uri.parse(geocodeUrl));
    final geoData = json.decode(geoResponse.body);

    if (geoData["status"] != "OK") {
      print("Geocoding failed: ${geoData["status"]}");
      return;
    }

    final destLat = geoData["results"][0]["geometry"]["location"]["lat"];
    final destLng = geoData["results"][0]["geometry"]["location"]["lng"];
    final destCoords = "$destLat,$destLng";

    final directionsUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destCoords&key=AIzaSyAX2a-xMEQ2VB_oPdtoD5o8IZLeCUWYTqU";
    final dirResponse = await http.get(Uri.parse(directionsUrl));
    final dirData = json.decode(dirResponse.body);

    if (dirData["status"] == "OK") {
      final points = dirData["routes"][0]["overview_polyline"]["points"];
      final decodedPoints = _decodePolyline(points);

      setState(() {
        _polylines.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId("destination"),
            position: LatLng(destLat, destLng),
            infoWindow: const InfoWindow(title: "Destination"),
          ),
        );

        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            points: decodedPoints,
            color: Colors.blue,
            width: 5,
          ),
        );
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: decodedPoints.first,
            northeast: decodedPoints.last,
          ),
          50,
        ),
      );
    } else {
      print("Directions API failed: ${dirData["status"]}");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          _currentPosition == null
              ? const Center(child: CupertinoActivityIndicator(radius: 16))
              : GoogleMap(
                  myLocationEnabled: true,
                  markers: _markers,
                  polylines: _polylines,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
          // iOS-style search bar with blur
          Positioned(
            top: 50,
            left: 12,
            right: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.search,
                          color: CupertinoColors.systemGrey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CupertinoTextField.borderless(
                          controller: destinationController,
                          placeholder: "Enter destination",
                          onSubmitted: (value) => _getRoute(value),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                            CupertinoIcons.arrow_right_circle_fill,
                            color: CupertinoColors.activeBlue),
                        onPressed: () {
                          _getRoute(destinationController.text);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Cupertino-style Report button
          Positioned(
            bottom: 40,
            left: MediaQuery.of(context).size.width * 0.25,
            right: MediaQuery.of(context).size.width * 0.25,
            child: CupertinoButton.filled(
              borderRadius: BorderRadius.circular(30),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.exclamationmark_triangle_fill,
                      color: CupertinoColors.white),
                  SizedBox(width: 8),
                  Text(
                    "Report",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                if (_currentPosition != null) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => ReportScreen(
                        latitude: _currentPosition!.latitude,
                        longitude: _currentPosition!.longitude,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
