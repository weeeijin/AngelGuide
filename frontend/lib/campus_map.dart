import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// You will create this screen separately
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
    return Scaffold(
      body: Stack(
        children: [
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
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
          // Search bar
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Card(
              child: TextField(
                controller: destinationController,
                decoration: InputDecoration(
                  hintText: "Enter destination",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _getRoute(destinationController.text);
                    },
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
                onSubmitted: (value) {
                  _getRoute(value);
                },
              ),
            ),
          ),
          // Report button (middle bottom)
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width * 0.35,
            right: MediaQuery.of(context).size.width * 0.35,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(150, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // <- curve
                ),
              ),
              icon: const Icon(Icons.report),
              label: const Text(
                "Report",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (_currentPosition != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
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
