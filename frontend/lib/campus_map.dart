import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  late GoogleMapController mapController;

  // Example: Universiti Malaya coordinates
  final LatLng _umLocation = const LatLng(3.1201, 101.6544);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campus Map")),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _umLocation,
          zoom: 15, // closer zoom to campus
        ),
        myLocationEnabled: true, // show user's live location
        myLocationButtonEnabled: true,
      ),
    );
  }
}
