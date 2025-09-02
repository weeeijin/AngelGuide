import 'package:flutter/material.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onLongPress: () {
            // TODO: Handle SOS trigger here (alarm, location, mic, etc.)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("🚨 SOS Activated!")));
          },
          child: Container(
            width: 150, // make it big
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle, // makes it round
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 3,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "SOS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
