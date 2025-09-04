import 'package:flutter/material.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF1ED6C1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background clouds and trees (replace with your own images if available)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/bg_clouds.png', // Replace with your asset or use Container for placeholder
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: 0,
              child: Opacity(
                opacity: 0.7,
                child: Image.asset(
                  'assets/bg_trees_left.png', // Replace with your asset or use Container for placeholder
                  height: 120,
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              right: 0,
              child: Opacity(
                opacity: 0.7,
                child: Image.asset(
                  'assets/bg_trees_right.png', // Replace with your asset or use Container for placeholder
                  height: 120,
                ),
              ),
            ),
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top search bar and icons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Icon(Icons.search, color: Colors.grey.shade400),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Search Safest Route to...",
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.more_vert, color: Colors.grey.shade400),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _ChipButton(label: "Home", icon: Icons.home, color: mainColor),
                          const SizedBox(width: 8),
                          _ChipButton(label: "School", icon: Icons.school, color: mainColor),
                          const SizedBox(width: 8),
                          _ChipButton(label: "Work", icon: Icons.work, color: mainColor),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          child: const Text(
                            "Get Free Stuff",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Big SOS button
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: mainColor.withOpacity(0.08),
                    ),
                    child: Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mainColor,
                        ),
                        child: Center(
                          child: Text(
                            "Hold to Start\nEmergency Mode",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Message box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: mainColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Add your first Angel and both you and your Angel will get a free week of Haven Premium. Now that's a WIN–WIN!",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Spacer(),
                // Bottom navigation
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0, left: 24, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BottomNavIcon(icon: Icons.menu_book),
                      _BottomNavIcon(icon: Icons.map),
                      Container(
                        decoration: BoxDecoration(
                          color: mainColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Icon(Icons.home, color: Colors.white, size: 32),
                      ),
                      _BottomNavIcon(icon: Icons.people),
                      _BottomNavIcon(icon: Icons.menu),
                    ],
                  ),
                ),
              ],
            ),
            // Location icon floating
            Positioned(
              bottom: 140,
              right: 32,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: mainColor, width: 2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: mainColor.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.my_location, color: mainColor, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _ChipButton({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  final IconData icon;
  const _BottomNavIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: const Color(0xFF1ED6C1), size: 32);
  }
}
