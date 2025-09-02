// lib/campus_map.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  GoogleMapController? _mapController;
  final Map<MarkerId, Marker> _markers = {};
  StreamSubscription<Position>? _positionStream;
  bool _permissionGranted = false;

  static const LatLng _initialLatLng = LatLng(
    3.1201,
    101.6544,
  ); // change to campus coords
  static const CameraPosition _initialCamera = CameraPosition(
    target: _initialLatLng,
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    _initLocationTracking();
  }

  Future<void> _initLocationTracking() async {
    // 1) Ensure location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // prompt the user to enable location services
      await Geolocator.openLocationSettings();
      // continue — user may enable and return
    }

    // 2) Request/check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      setState(() => _permissionGranted = false);
      // Permission denied, bail out (UI will show button to retry)
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _permissionGranted = false);
      // Denied forever — ask user to open app settings
      if (mounted) {
        _showOpenSettingsDialog();
      }
      return;
    }

    // permission granted
    setState(() => _permissionGranted = true);

    // 3) Get current position once and update marker/camera
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _updateUserMarker(pos, moveCamera: true);
    } catch (e) {
      // Could be a timeout or permission issue
      debugPrint('getCurrentPosition error: $e');
    }

    // 4) Subscribe to continuous location updates
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5, // meters — only get updates when user moves 5m
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _updateUserMarker(position, moveCamera: false);
            // optionally move camera to follow user:
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 17,
                ),
              ),
            );
          },
        );
  }

  void _updateUserMarker(Position pos, {bool moveCamera = false}) {
    final markerId = const MarkerId('user_marker');
    final marker = Marker(
      markerId: markerId,
      position: LatLng(pos.latitude, pos.longitude),
      infoWindow: const InfoWindow(title: 'You'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    setState(() {
      _markers[markerId] = marker;
    });

    if (moveCamera) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 17),
        ),
      );
    }
  }

  Future<void> _showOpenSettingsDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Location permission required'),
        content: const Text(
          'Please grant location permission in app settings to show your position.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Widget _buildEnableLocationOverlay() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: ElevatedButton(
        onPressed: _initLocationTracking,
        child: const Text('Enable Location'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Map')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialCamera,
            markers: Set<Marker>.of(_markers.values),
            myLocationEnabled: _permissionGranted,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          if (!_permissionGranted) _buildEnableLocationOverlay(),
        ],
      ),
    );
  }
}
