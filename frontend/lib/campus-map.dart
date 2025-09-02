import 'package:flutter/material.dart';

class CampusMapScreen extends StatelessWidget {
  const CampusMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campus Map")),
      body: InteractiveViewer(
        minScale: 0.5, // allow zoom out
        maxScale: 4.0, // allow zoom in
        child: Image.asset("assets/um-campus-map.jpg"),
      ),
    );
  }
}
